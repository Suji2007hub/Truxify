import request from 'supertest';
import { app, server } from '../../src/app.js';
import { supabase, redisClient } from '../../src/config/db.js';
import { getTestUser, testOrderPayload } from '../helpers.js';

describe('Truxify API - Order & Load Board Workflows', () => {

  afterAll(async () => {
    // Clean up test data
    await supabase.from('orders').delete().neq('id', 0);
    await supabase.from('load_offers').delete().neq('id', 0);
    await supabase.from('load_bids').delete().neq('id', 0);
    await supabase.from('order_timeline').delete().neq('id', 0);
    await supabase.from('trips').delete().neq('id', 0);

    // Close server and Redis connections
    server.close();
    await redisClient.quit();
  });

  // ============================================================================
  // 1. Order Creation
  // ============================================================================
  describe('POST /api/orders', () => {
    it('should create an order, timeline, and load offer successfully for a customer', async () => {
      const customer = await getTestUser('customer');
      const res = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send(testOrderPayload);

      expect(res.statusCode).toEqual(201);
      expect(res.body.message).toContain('Order created successfully');
      expect(res.body.order.order_display_id).toMatch(/^#FF\d{12}$/);

      const orderId = res.body.order.order_display_id;

      // Verify timeline was created
      const { data: timeline } = await supabase
        .from('order_timeline')
        .select('*')
        .eq('order_display_id', orderId);
      expect(timeline.length).toBe(6);
      expect(timeline[0].milestone).toBe('Order Placed');
      expect(timeline[0].completed).toBe(true);

      // Verify load offer was created
      const { data: offer } = await supabase
        .from('load_offers')
        .select('*')
        .eq('order_display_id', orderId)
        .single();
      expect(offer).not.toBeNull();
      expect(offer.status).toBe('available');
    });

    it('should be rejected for a user with a driver role', async () => {
      const driver = await getTestUser('driver');
      const res = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${driver.token}`)
        .send(testOrderPayload);

      expect(res.statusCode).toEqual(403);
    });
  });

  // ============================================================================
  // 2. Bidding on a Load Offer
  // ============================================================================
  describe('POST /api/orders/:id/bids', () => {
    let loadOfferId;
    let customerToken;

    beforeAll(async () => {
      const customer = await getTestUser('customer');
      customerToken = customer.token;
      const res = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${customerToken}`)
        .send(testOrderPayload);
      const orderDisplayId = res.body.order.order_display_id;
      const { data: offer } = await supabase.from('load_offers').select('id').eq('order_display_id', orderDisplayId).single();
      loadOfferId = offer.id;
    });

    it('should allow a driver to submit a bid', async () => {
      const driver = await getTestUser('driver');
      const res = await request(app)
        .post(`/api/orders/${loadOfferId}/bids`)
        .set('Authorization', `Bearer ${driver.token}`)
        .send({ bid_amount: 500000 }); // 5000.00

      expect(res.statusCode).toEqual(201);
      expect(res.body.message).toContain('Bid submitted successfully');
      expect(res.body.bid.load_id).toBe(loadOfferId);
      expect(res.body.bid.bid_amount).toBe(500000);
    });

    it('should prevent a customer from submitting a bid', async () => {
      const res = await request(app)
        .post(`/api/orders/${loadOfferId}/bids`)
        .set('Authorization', `Bearer ${customerToken}`)
        .send({ bid_amount: 500000 });

      expect(res.statusCode).toEqual(403);
    });
  });

  // ============================================================================
  // 3. Accepting a Bid
  // ============================================================================
  describe('POST /api/orders/:id/bids/:bidId/accept', () => {
    let orderId;
    let bidId;
    let customerToken;

    beforeAll(async () => {
      const customer = await getTestUser('customer');
      const driver = await getTestUser('driver');
      customerToken = customer.token;

      const orderRes = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${customerToken}`)
        .send(testOrderPayload);
      orderId = orderRes.body.order.id;
      const orderDisplayId = orderRes.body.order.order_display_id;

      const { data: offer } = await supabase.from('load_offers').select('id').eq('order_display_id', orderDisplayId).single();
      const bidRes = await request(app)
        .post(`/api/orders/${offer.id}/bids`)
        .set('Authorization', `Bearer ${driver.token}`)
        .send({ bid_amount: 480000 });
      bidId = bidRes.body.bid.id;
    });

    it('should allow a customer to accept a bid, assigning the driver and truck', async () => {
      const res = await request(app)
        .post(`/api/orders/${orderId}/bids/${bidId}/accept`)
        .set('Authorization', `Bearer ${customerToken}`);

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toContain('Bid accepted');

      // Verify order status and driver assignment
      const { data: order } = await supabase.from('orders').select('status, driver_id').eq('id', orderId).single();
      expect(order.status).toBe('confirmed');
      expect(order.driver_id).not.toBeNull();

      // Verify bid status
      const { data: bid } = await supabase.from('load_bids').select('status').eq('id', bidId).single();
      expect(bid.status).toBe('accepted');

      // Verify a trip record was created
      const { data: trip } = await supabase.from('trips').select('*').eq('order_id', orderId).single();
      expect(trip).not.toBeNull();
      expect(trip.status).toBe('not_started');
    });
  });

  // ============================================================================
  // 8. OTP-based Delivery Verification & Trip Completion
  // ============================================================================
  describe('POST /api/orders/:id/verify-otp', () => {
    let orderId;
    let orderDisplayId;
    let driverToken;

    beforeAll(async () => {
      // Create a complete order scenario: Customer creates order, Driver bids, Customer accepts
      const customer = await getTestUser('customer');
      const driver = await getTestUser('driver');
      driverToken = driver.token;

      // 1. Customer creates an order
      const orderRes = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send(testOrderPayload);
      orderId = orderRes.body.order.id;
      orderDisplayId = orderRes.body.order.order_display_id;

      // 2. Find the load offer for the new order
      const { data: offer } = await supabase
        .from('load_offers')
        .select('id')
        .eq('order_display_id', orderDisplayId)
        .single();

      // 3. Driver places a bid
      const bidRes = await request(app)
        .post(`/api/orders/${offer.id}/bids`)
        .set('Authorization', `Bearer ${driver.token}`)
        .send({ bid_amount: 450000 });
      const bidId = bidRes.body.bid.id;

      // 4. Customer accepts the bid
      await request(app)
        .post(`/api/orders/${orderId}/bids/${bidId}/accept`)
        .set('Authorization', `Bearer ${customer.token}`);

      // 5. Driver updates milestone to 'In Transit' to trigger OTP generation
      await request(app)
        .put(`/api/orders/${orderId}/milestones`)
        .set('Authorization', `Bearer ${driver.token}`)
        .send({ milestone: 'In Transit' });
    });

    it('should reject with 400 for an invalid OTP', async () => {
      const res = await request(app)
        .post(`/api/orders/${orderId}/verify-otp`)
        .set('Authorization', `Bearer ${driverToken}`)
        .send({ otp: '000000' });

      expect(res.statusCode).toEqual(400);
      expect(res.body.error).toEqual('Invalid OTP.');

      // Check that attempts counter was decremented
      const attemptsLeft = await redisClient.get(`otp_attempts:${orderDisplayId}`);
      expect(attemptsLeft).toBe('2');
    });

    it('should reject with 429 after too many failed attempts', async () => {
      // First attempt (already done in previous test, 2 left)
      // Second attempt
      await request(app)
        .post(`/api/orders/${orderId}/verify-otp`)
        .set('Authorization', `Bearer ${driverToken}`)
        .send({ otp: '000001' });

      // Third attempt
      await request(app)
        .post(`/api/orders/${orderId}/verify-otp`)
        .set('Authorization', `Bearer ${driverToken}`)
        .send({ otp: '000002' });

      const attemptsLeft = await redisClient.get(`otp_attempts:${orderDisplayId}`);
      expect(attemptsLeft).toBe('0');

      // Fourth attempt should be locked
      const res = await request(app)
        .post(`/api/orders/${orderId}/verify-otp`)
        .set('Authorization', `Bearer ${driverToken}`)
        .send({ otp: '000003' });

      expect(res.statusCode).toEqual(429);
      expect(res.body.error).toContain('Too many failed attempts');
    });

    it('should successfully verify a valid OTP and complete the trip', async () => {
      // We need a fresh OTP for this test
      const driver = await getTestUser('driver');
      const customer = await getTestUser('customer');
      const orderRes = await request(app)
        .post('/api/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send(testOrderPayload);
      const newOrderId = orderRes.body.order.id;
      const newOrderDisplayId = orderRes.body.order.order_display_id;

      const { data: offer } = await supabase.from('load_offers').select('id').eq('order_display_id', newOrderDisplayId).single();
      const bidRes = await request(app).post(`/api/orders/${offer.id}/bids`).set('Authorization', `Bearer ${driver.token}`).send({ bid_amount: 450000 });
      await request(app).post(`/api/orders/${newOrderId}/bids/${bidRes.body.bid.id}/accept`).set('Authorization', `Bearer ${customer.token}`);
      await request(app).put(`/api/orders/${newOrderId}/milestones`).set('Authorization', `Bearer ${driver.token}`).send({ milestone: 'In Transit' });

      // Retrieve the valid OTP from Redis
      const validOtp = await redisClient.get(`otp:${newOrderDisplayId}`);
      expect(validOtp).not.toBeNull();

      const res = await request(app)
        .post(`/api/orders/${newOrderId}/verify-otp`)
        .set('Authorization', `Bearer ${driver.token}`)
        .send({
          otp: validOtp,
          hours_driven: 5.5,
          end_time: new Date().toISOString()
        });

      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toEqual('Delivery confirmed and trip completed successfully.');

      // Verify final milestone is marked as complete
      const { data: timeline } = await supabase
        .from('order_timeline')
        .select('completed')
        .eq('order_display_id', newOrderDisplayId)
        .eq('milestone', 'Delivered')
        .single();
      expect(timeline.completed).toBe(true);

      // Verify trip status is updated
      const { data: trip } = await supabase
        .from('trips')
        .select('status')
        .eq('trip_display_id', newOrderDisplayId)
        .single();
      expect(trip.status).toEqual('completed');

      // Verify Redis keys were deleted
      const otpKey = await redisClient.get(`otp:${newOrderDisplayId}`);
      const attemptsKey = await redisClient.get(`otp_attempts:${newOrderDisplayId}`);
      expect(otpKey).toBeNull();
      expect(attemptsKey).toBeNull();
    });
  });
});