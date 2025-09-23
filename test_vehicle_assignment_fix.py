#!/usr/bin/env python3

import requests
import json
import sys

def test_vehicle_assignment():
    """Test vehicle assignment API to ensure it handles existing assignments properly"""
    
    base_url = "http://localhost:8001/api"
    
    # First, get auth token for kuvuki@kuvuki.com
    login_data = {
        "email": "kuvuki@kuvuki.com",
        "password": "driver123"  # Default password
    }
    
    print("1. Testing login...")
    login_response = requests.post(f"{base_url}/drivers/login/", json=login_data)
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")
        return False
    
    token = login_response.json()['token']
    print(f"✅ Login successful, token: {token[:20]}...")
    
    headers = {
        "Authorization": f"Token {token}",
        "Content-Type": "application/json"
    }
    
    # Check existing assignments
    print("\n2. Checking existing assignments...")
    assignments_response = requests.get(f"{base_url}/driver-armada/", headers=headers)
    
    if assignments_response.status_code == 200:
        assignments = assignments_response.json()
        print(f"✅ Current assignments: {len(assignments)}")
        for assignment in assignments:
            print(f"   - Driver {assignment['id_driver']} -> Vehicle {assignment['id_armada']}")
    else:
        print(f"❌ Failed to get assignments: {assignments_response.status_code}")
        return False
    
    # Try to assign the same vehicle again (should not fail)
    print("\n3. Testing duplicate assignment...")
    assignment_data = {
        "id_armada": 1,
        "tanggal_mulai": "2025-01-15T10:00:00Z",
        "tanggal_selesai": "2026-01-15T10:00:00Z"
    }
    
    assignment_response = requests.post(f"{base_url}/driver-armada/", 
                                      json=assignment_data, 
                                      headers=headers)
    
    print(f"Assignment response status: {assignment_response.status_code}")
    print(f"Assignment response body: {assignment_response.text}")
    
    if assignment_response.status_code in [200, 201]:
        print("✅ Assignment handled correctly (no duplicate error)")
        return True
    else:
        print(f"❌ Assignment failed: {assignment_response.status_code}")
        return False

if __name__ == "__main__":
    print("Testing Vehicle Assignment Fix")
    print("=" * 40)
    
    success = test_vehicle_assignment()
    
    if success:
        print("\n🎉 All tests passed! The fix is working correctly.")
        sys.exit(0)
    else:
        print("\n💥 Tests failed! There are still issues.")
        sys.exit(1)