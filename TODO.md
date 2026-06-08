# Truxify — OTP verification & payout workflow (TODO)

## Completed
- [x] Expose OTP verification endpoint: `POST /api/orders/:id/verify-otp` (driver auth + role + assignment check)
- [x] Generate 6-digit numeric OTP on milestone transition to `In Transit`
- [x] Store OTP in Redis with TTL 24h (EX 86400) under `order:otp:${orderDisplayId}`
- [x] Verify OTP using Redis match; invalid OTP => 400
- [x] Trigger Supabase RPC `complete_trip_tx` upon successful verification
- [x] Mark `Delivered` milestone completed after successful RPC
- [x] Brute-force protection via Redis attempts key `order:otp:attempts:${orderDisplayId}`; max 3; lockout => 429
- [x] Update integration tests to use `/verify-otp`



