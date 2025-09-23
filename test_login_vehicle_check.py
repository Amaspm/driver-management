#!/usr/bin/env python3

import requests
import json

def test_login_with_vehicle_check():
    """Test login endpoint returns vehicle information"""
    
    base_url = "http://localhost:8001/api"
    
    # Test login for kuvuki@kuvuki.com
    login_data = {
        "email": "kuvuki@kuvuki.com",
        "password": "driver123"
    }
    
    print("Testing login with vehicle check...")
    login_response = requests.post(f"{base_url}/drivers/login/", json=login_data)
    
    if login_response.status_code == 200:
        data = login_response.json()
        print(f"✅ Login successful")
        print(f"   Token: {data['token'][:20]}...")
        print(f"   Driver ID: {data['driver_id']}")
        print(f"   Status: {data['status']}")
        print(f"   Has Vehicle: {data['has_vehicle']}")
        
        if data['status'] == 'active' and data['has_vehicle']:
            print("✅ Driver should go to dashboard")
        elif data['status'] == 'active' and not data['has_vehicle']:
            print("✅ Driver should go to vehicle matching")
        else:
            print(f"✅ Driver should handle status: {data['status']}")
            
        return True
    else:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")
        return False

if __name__ == "__main__":
    print("Testing Login Vehicle Check")
    print("=" * 30)
    
    success = test_login_with_vehicle_check()
    
    if success:
        print("\n🎉 Login vehicle check working correctly!")
    else:
        print("\n💥 Login vehicle check failed!")