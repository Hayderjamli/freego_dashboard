# FreeGo Smart Solar Freezer Dashboard

A modern Flutter mobile app for monitoring and controlling the FreeGo smart solar freezer prototype. Receives real-time data from a Raspberry Pi (temperature, humidity, camera snapshots, etc.).

## Features

### Dashboard Home
- Big temperature card with real-time readings
- Big humidity card with current levels
- Battery/Solar input cards showing power status
- Real-time status indicator ("LIVE")
- Top bar showing device name + connectivity status

### Charts Page
- Line chart for temperature (real-time or historical)
- Line chart for humidity
- Time range selector (1h, 24h, 7d, 30d)

### Live Monitor
- WebSocket connection to Raspberry Pi
- Camera feed streaming
- Real-time sensor data display
- Connection status indicator

### Alerts Page
- High temperature warnings
- Low battery alerts
- Communication failure notifications
- Swipe to dismiss alerts

### Settings Page
- Device information display
- WebSocket endpoint configuration
- Alert threshold settings
- Dark mode toggle (stub)
- Sign out functionality

## Color Palette

- **Primary**: #2D9CDB (cool blue)
- **Secondary**: #27AE60 (green for "healthy" status)
- **Accent**: #F2C94C (warning yellow)
- **Danger**: #EB5757 (red for alerts)
- **Background**: #F7F9FC
- **Text/Dark**: #1A1A1A

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── models.dart          # Data models
│   └── theme/
│       ├── app_colors.dart      # Color palette
│       └── app_theme.dart       # Theme configuration
├── features/
│   ├── alerts/
│   │   └── alerts_page.dart     # Alerts page
│   ├── charts/
│   │   └── charts_page.dart     # Charts page
│   ├── dashboard/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── dashboard_home_page.dart
│   └── settings/
│       └── settings_page_new.dart
├── shared/
│   └── widgets/
│       └── dashboard_widgets.dart   # Reusable components
├── main.dart                    # App entry point
├── welcome_page.dart            # Welcome screen
├── login_page.dart              # Login screen
├── signup_page.dart             # Signup screen
├── pi_monitor_page.dart         # Live monitor screen
├── notification_service.dart    # Alert service
└── auth_service.dart           # Authentication service
```

## Run Locally

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Tests

```bash
flutter test
```

## Dependencies

- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Cloud database
- **fl_chart**: Beautiful charts
- **web_socket_channel**: WebSocket communication

## WebSocket Configuration

The app connects to the Raspberry Pi at:
```
ws://192.168.137.104:8000
```

This can be changed in the Settings page or in `pi_monitor_page.dart`.

## Backend Communication

The app maintains real-time communication with the Raspberry Pi using WebSockets:

- Sensor data is received as JSON with type `sensor`
- Camera frames are received as base64-encoded data with type `frame`
- Auto-reconnect on connection loss
- Start/stop streaming commands: `START_STREAM:15` / `STOP_STREAM`

## License

This project is part of the FreeGo smart solar freezer prototype.
