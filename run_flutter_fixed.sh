#!/bin/bash

echo "🚀 Running Flutter with Fixed Configuration"
echo "=========================================="

cd frontend

# Clean and get dependencies
echo "1. Cleaning Flutter project..."
flutter clean
flutter pub get

# Check if we can build
echo "2. Testing build..."
flutter analyze --no-fatal-infos

# Run Flutter
echo "3. Starting Flutter app..."
echo "Available devices:"
flutter devices

echo -e "\nStarting app..."
flutter run --debug