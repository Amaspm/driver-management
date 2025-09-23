#!/bin/bash

echo "=== Run Flutter Web ==="

# Update Flutter config for web (use localhost)
sed -i "s/static const String mode = .*/static const String mode = 'emulator';/" lib/config/api_config.dart
echo "✓ Flutter config updated for web"

# Run Flutter web
flutter run -d chrome --web-port 3001