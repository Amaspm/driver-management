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

def cleanup_orphaned_users(token):
    """Cleanup orphaned users"""
    headers = {"Authorization": f"Token {token}"}
    response = requests.post(f"{BASE_URL}/admin/cleanup-users/", headers=headers)
    
    print(f"Cleanup response status: {response.status_code}")
    print(f"Cleanup response: {response.text}")
    
    return response.status_code == 200

def main():
    print("=== Testing Delete Function ===")
    
    # Get admin token
    token = get_admin_token()
    if not token:
        return
    
    print(f"Admin token obtained: {token[:20]}...")
    
    # Get all drivers
    drivers = get_all_drivers(token)
    print(f"\nCurrent drivers in database:")
    for driver in drivers:
        print(f"ID: {driver['id_driver']}, Email: {driver['email']}, Nama: {driver['nama']}, Status: {driver['status']}")
    
    # Test cleanup function
    print(f"\n=== Testing Cleanup Function ===")
    cleanup_result = cleanup_orphaned_users(token)
    
    # Get drivers again to see current state
    print(f"\n=== Drivers after cleanup ===")
    drivers_after = get_all_drivers(token)
    for driver in drivers_after:
        print(f"ID: {driver['id_driver']}, Email: {driver['email']}, Nama: {driver['nama']}, Status: {driver['status']}")

if __name__ == "__main__":
    main()