#!/usr/bin/env python3
"""
Test script untuk memverifikasi alur notifikasi driver
"""
import requests
import json
import time
import sys

def test_notification_flow():
    base_url = "http://localhost:8001/api"
    
    print("🧪 Testing Driver Notification Flow...")
    
    # Test 1: Create Order (User)
    print("\n1️⃣ Testing Order Creation...")
    order_data = {
        "barang": "Barang Test",
        "kota": "Jakarta"
    }
    
    try:
        response = requests.post(f"{base_url}/order/create/", json=order_data)
        if response.status_code == 200:
            result = response.json()
            order_id = result['order_id']
            print(f"✅ Order created: {order_id}")
        else:
            print(f"❌ Failed to create order: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error creating order: {e}")
        return False
    
    # Test 2: Confirm Order (Seller)
    print("\n2️⃣ Testing Order Confirmation...")
    confirm_data = {
        "order_id": order_id,
        "pickup": "Alamat Pickup Test",
        "tujuan": "Barang Test ke Jakarta",
        "kota": "Jakarta"
    }
    
    try:
        response = requests.post(f"{base_url}/order/confirmed/", json=confirm_data)
        if response.status_code == 200:
            print("✅ Order confirmed and sent to drivers")
        else:
            print(f"❌ Failed to confirm order: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error confirming order: {e}")
        return False
    
    # Test 3: Check Driver Service
    print("\n3️⃣ Testing Driver Service...")
    try:
        response = requests.get("http://localhost:8080/drivers/online")
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Driver service responding: {len(result.get('connected_drivers', []))} connected drivers")
        else:
            print(f"❌ Driver service not responding: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error connecting to driver service: {e}")
        return False
    
    # Test 4: Simulate Driver Response
    print("\n4️⃣ Testing Driver Response...")
    response_data = {
        "driver_id": "test_driver_1",
        "order_id": order_id,
        "action": "terima"
    }
    
    try:
        response = requests.post(f"{base_url}/order/response/", json=response_data)
        if response.status_code == 200:
            print("✅ Driver response processed")
        else:
            print(f"❌ Failed to process driver response: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error processing driver response: {e}")
        return False
    
    # Test 5: Check Final Order Status
    print("\n5️⃣ Checking Final Order Status...")
    try:
        response = requests.get(f"{base_url}/orders/?status=sedang_dikirim")
        if response.status_code == 200:
            result = response.json()
            orders = result.get('orders', [])
            if any(order['order_id'] == order_id for order in orders):
                print("✅ Order status updated correctly")
            else:
                print("❌ Order status not updated")
                return False
        else:
            print(f"❌ Failed to get orders: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error getting orders: {e}")
        return False
    
    print("\n🎉 All tests passed! Notification system is working correctly.")
    return True

if __name__ == "__main__":
    success = test_notification_flow()
    sys.exit(0 if success else 1)