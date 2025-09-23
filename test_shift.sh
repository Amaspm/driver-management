#!/bin/bash

echo "🚀 Testing Driver Shift System"
echo "================================"

# Test 1: Driver goes online
echo "1. Testing driver online..."
curl -X POST http://localhost:8080/driver/status \
  -H "Content-Type: application/json" \
  -d '{"driver_id":"driver_001","kota":"jakarta","status":"online"}'
echo -e "\n"

sleep 2

# Test 2: Seller confirms order
echo "2. Testing order confirmation..."
curl -X POST http://localhost:8001/api/order/confirmed \
  -H "Content-Type: application/json" \
  -d '{"order_id":"order_123","pickup":"Jl. Sudirman","tujuan":"Jl. Thamrin","kota":"jakarta"}'
echo -e "\n"

sleep 2

# Test 3: Driver accepts order
echo "3. Testing driver accepts order..."
curl -X POST http://localhost:8001/api/order/response \
  -H "Content-Type: application/json" \
  -d '{"driver_id":"driver_001","order_id":"order_123","action":"terima"}'
echo -e "\n"

sleep 2

# Test 4: Driver goes offline
echo "4. Testing driver offline..."
curl -X POST http://localhost:8080/driver/status \
  -H "Content-Type: application/json" \
  -d '{"driver_id":"driver_001","status":"offline"}'
echo -e "\n"

echo "✅ Testing completed!"