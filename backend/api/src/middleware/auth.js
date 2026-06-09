import { firebaseAdmin, supabase, redisClient } from '../config/db.js';

const PROFILE_CACHE_TTL_SECONDS = 15 * 60; // 900

function getProfileCacheKey(firebaseUid) {
  return `user:profile:${firebaseUid}`;
}

/**
 * Invalidate cached profile for a given Firebase UID.
 *
 * This is intended to be called by profile update routes/services.
 */
export async function invalidateUserProfileCache(firebaseUid) {
  if (!firebaseUid) return;
  if (!redisClient) return;

  const cacheKey = getProfileCacheKey(firebaseUid);
  try {
    await redisClient.del(cacheKey);
  } catch (err) {
    console.error('[auth] Failed to invalidate profile cache:', err?.message || err);
  }
}

/**
 * Authentication middleware to verify requests using Firebase ID Tokens.
 * Supports BYPASS_AUTH=true environment variable for easy local testing.
 */
export async function authenticate(req, res, next) {
  const bypassAuth = process.env.BYPASS_AUTH === 'true';

  // Support local development bypass mode
  if (bypassAuth) {
    if (process.env.NODE_ENV === 'production') {
      return res.status(503).json({
        error: 'BYPASS_AUTH is enabled in production. This is a misconfiguration and must be disabled before serving traffic.'
      });
    }
    const testUserId = req.headers['x-user-id']; // e.g. a Supabase profile UUID
    const testUserRole = req.headers['x-user-role'] || 'customer'; // customer or driver
    const testFullName = req.headers['x-user-name'] || 'Test User';

    if (testUserId) {
      req.user = {
        id: testUserId,
        uid: 'test_firebase_uid_123',
        role: testUserRole,
        fullName: testFullName,
        phone: '+919999999999'
      };
      return next();
    } else {
      return res.status(401).json({
        error: 'Authentication bypassed but x-user-id header is missing.',
        hint: 'Provide a valid profile UUID in the x-user-id header when BYPASS_AUTH is enabled.'
      });
    }
  }

  // Regular Firebase Authentication Flow
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Access Denied. No token provided.' });
  }

  const token = authHeader.split(' ')[1];

  if (!firebaseAdmin) {
    return res.status(500).json({ error: 'Firebase Auth verification is not configured on this server.' });
  }

  try {
    // 1. Verify token with Firebase
    const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
    const firebaseUid = decodedToken.uid;

    if (!supabase) {
      return res.status(500).json({ error: 'Supabase client is not configured on this server.' });
    }

    // 2. Try to fetch profile from Redis cache first
    const cacheKey = getProfileCacheKey(firebaseUid);
    if (redisClient) {
      try {
        const cached = await redisClient.get(cacheKey);
        if (cached) {
          const profile = JSON.parse(cached);
          req.user = {
            id: profile.id,
            uid: profile.firebase_uid,
            role: profile.role,
            fullName: profile.full_name,
            phone: profile.phone
          };
          return next();
        }
      } catch (cacheErr) {
        console.error('[auth] Redis cache read failed:', cacheErr?.message || cacheErr);
        // fall back to DB lookup
      }
    }

    // 3. Cache miss (or Redis unavailable): Fetch corresponding profile from Supabase
    const { data: profile, error } = await supabase
      .from('profiles')
      .select('id, firebase_uid, role, full_name, phone')
      .eq('firebase_uid', firebaseUid)
      .eq('is_active', true)
      .maybeSingle();

    if (error) {
      return res.status(500).json({ error: 'Database query failed verification', details: error.message });
    }

    if (!profile) {
      return res.status(403).json({ 
        error: 'User profile not found in database.',
        hint: 'Register user in profiles table first using user_id linked to Firebase UID.' 
      });
    }

    // 4. Attach user data to request context
    req.user = {
      id: profile.id,
      uid: profile.firebase_uid,
      role: profile.role,
      fullName: profile.full_name,
      phone: profile.phone
    };

    // 5. Store profile in Redis for subsequent requests (best-effort)
    if (redisClient) {
      try {
        await redisClient.set(
          cacheKey,
          JSON.stringify(profile),
          'EX',
          PROFILE_CACHE_TTL_SECONDS
        );
      } catch (cacheErr) {
        console.error('[auth] Redis cache write failed:', cacheErr?.message || cacheErr);
        // do not fail auth
      }
    }

    next();
  } catch (error) {
    console.error('Auth verification error:', error.message);
    res.status(401).json({ error: 'Invalid or expired authentication token.' });
  }
}


/**
 * Middleware to restrict route access to specific roles.
 * Must be used after authenticate middleware.
 */
export function requireRole(allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(501).json({ error: 'Security middleware configuration error.' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: 'Forbidden: Insufficient privileges.',
        details: `Your account role '${req.user.role}' is not authorized to access this resource.`
      });
    }

    next();
  };
}
