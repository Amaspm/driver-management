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

def check_sync_status(token):
    """Check database sync status"""
    headers = {"Authorization": f"Token {token}"}
    response = requests.get(f"{BASE_URL}/admin/check-sync/", headers=headers)
    
    print(f"Sync check response status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Sync Status: {'✓ Synchronized' if data['is_synchronized'] else '✗ Not Synchronized'}")
        print(f"Total Users: {data['total_users']}")
        print(f"Total Drivers: {data['total_drivers']}")
        print(f"Orphaned Users: {data['orphaned_users_count']}")
        print(f"Drivers without Users: {data['drivers_without_users_count']}")
        
        if data['orphaned_users']:
            print("\nOrphaned Users:")
            for user in data['orphaned_users']:
                print(f"  - ID: {user['id']}, Email: {user['email']}")
        
        if data['drivers_without_users']:
            print("\nDrivers without Users:")
            for driver in data['drivers_without_users']:
                print(f"  - ID: {driver['id']}, Email: {driver['email']}, Name: {driver['nama']}")
        
        return data
    else:
        print(f"Sync check failed: {response.text}")
        return None

def main():
    print("=== Testing Database Sync Check ===")
    
    # Get admin token
    token = get_admin_token()
    if not token:
        return
    
    print(f"Admin token obtained: {token[:20]}...")
    
    # Check sync status
    sync_data = check_sync_status(token)

if __name__ == "__main__":
    main()