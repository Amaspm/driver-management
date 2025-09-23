# Wireless Connection Guide

## Setup Wireless ADB Connection

### 1. Initial Setup (USB Required)
```bash
# Connect device via USB first
./setup_wireless.sh
```

### 2. Run App Wirelessly
```bash
# After wireless setup, disconnect USB and run:
./run_wireless.sh
```

### 3. Reconnect if Disconnected
```bash
./reconnect_wireless.sh
```

## Connection Scripts

- `quick_connect.sh` - USB connection with port forwarding
- `setup_wireless.sh` - Enable wireless ADB debugging
- `reconnect_wireless.sh` - Reconnect to saved wireless device
- `run_wireless.sh` - Run Flutter app on wireless device
- `run_android.sh` - Auto-detect and run (USB or wireless)
- `run_web.sh` - Run Flutter web version

## Troubleshooting

### Device Not Found
1. Ensure device and computer on same WiFi
2. Enable Developer Options and USB Debugging
3. Run `adb devices` to check connection

### IP Address Changed
1. Run `setup_wireless.sh` again
2. Or manually update IP in `lib/config/api_config.dart`

### Connection Lost
1. Run `reconnect_wireless.sh`
2. If fails, restart from USB setup