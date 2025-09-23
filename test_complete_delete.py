#!/usr/bin/env python3

import requests
import json

# Configuration
BASE_URL = "http://localhost:8001/api"
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin123"

def get_admin_token():
    """Get admin authentication token"""
    response = requests.post(f"{BASE_URL}/auth/admin-login/", {
        "username": ADMIN_USERNAME,
        "password": ADMIN_PASSWORD
    })
    
    if response.status_code == 200:
        return response.json()["token"]
    else:
        print(f"Failed to get admin token: {response.status_code}")
        print(response.text)
        return None

def create_test_driver(token):
    """Create a test driver for deletion"""
    headers = {"Authorization": f"Token {token}"}
    test_data = {
        "email": "test.delete@example.com",
        "password": "testpass123",
        "status": "training"
    }
    
    response = requests.post(f"{BASE_URL}/auth/create-driver/", json=test_data, headers=headers)
    
    if response.status_code == 201:
        data = response.json()
        print(f"Test driver created: ID {data['id']}, Email: {data['email']}")
        return data['id']
    else:
        print(f"Failed to create test driver: {response.status_code}")
        print(response.text)
        return None

def get_all_drivers(token):
    """Get all drivers from API"""
    headers = {"Authorization": f"Token {token}"}
    response = requests.get(f"{BASE_URL}/drivers/", headers=headers)
    
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to get drivers: {response.status_code}")
        print(response.text)
        return []

def delete_driver(token, driver_id):
    """Delete a driver"""
    headers = {"Authorization": f"Token {token}"}
    response = requests.delete(f"{BASE_URL}/drivers/{driver_id}/", headers=headers)
    
    print(f"Delete response status: {response.status_code}")
    if response.status_code != 204:
        print(f"Delete response: {response.text}")
    
    return response.status_code == 204

def check_sync_status(token):
    """Check database sync status"""
    headers = {"Authorization": f"Token {token}"}
    response = requests.get(f"{BASE_URL}/admin/check-sync/", headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        print(f"Sync Status: {'✓ Synchronized' if data['is_synchronized'] else '✗ Not Synchronized'}")
        print(f"Total Users: {data['total_users']}, Total Drivers: {data['total_drivers']}, Orphaned: {data['orphaned_users_count']}")
        return data
    else:
        print(f"Sync check failed: {response.text}")
        return None

def main():
    print("=== Testing Complete Delete Functionality ===")
    
    # Get admin token
    token = get_admin_token()
    if not token:
        return
    
    print(f"Admin token obtained: {token[:20]}...")
    
    # Check initial sync status
    print(f"\n=== Initial Sync Status ===")
    check_sync_status(token)
    
    # Create test driver
    print(f"\n=== Creating Test Driver ===")
    test_driver_id = create_test_driver(token)
    if not test_driver_id:
        return
    
    # Check sync after creation
    print(f"\n=== Sync Status After Creation ===")
    check_sync_status(token)
    
    # Get all drivers
    print(f"\n=== Current Drivers ===")
    drivers = get_all_drivers(token)
    for driver in drivers:
        print(f"ID: {driver['id_driver']}, Email: {driver['email']}, Nama: {driver['nama']}, Status: {driver['status']}")
    
    # Delete the test driver
    print(f"\n=== Deleting Test Driver (ID: {test_driver_id}) ===")
    delete_success = delete_driver(token, test_driver_id)
    
    if delete_success:
        print("✓ Driver deleted successfully")
    else:
        print("✗ Driver deletion failed")
    
    # Check sync after deletion
    print(f"\n=== Sync Status After Deletion ===")
    check_sync_status(token)
    
    # Get drivers again to confirm deletion
    print(f"\n=== Drivers After Deletion ===")
    drivers_after = get_all_drivers(token)
    for driver in drivers_after:
        print(f"ID: {driver['id_driver']}, Email: {driver['email']}, Nama: {driver['nama']}, Status: {driver['status']}")
    
    # Verify the test driver is gone
    test_driver_found = any(d['id_driver'] == test_driver_id for d in drivers_after)
    if not test_driver_found:
        print("✓ Test driver successfully removed from database")
    else:
        print("✗ Test driver still exists in database")

if __name__ == "__main__":
    main()