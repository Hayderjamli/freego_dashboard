# FreeGo Dashboard 🌿

A modern Flutter mobile application for monitoring and controlling the **FreeGo Smart Solar Freezer**. The app provides real-time monitoring of temperature, humidity, battery status, and device connectivity with a clean, intuitive interface.

![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.7.2-0175C2?logo=dart)

---

## 📱 Features

### 🏠 Dashboard Home
- **Real-time Metrics**: Large, easy-to-read cards displaying temperature, humidity, and battery/solar status
- **Device Status**: Live connection indicator and last sync timestamp
- **Green Theme**: Modern UI with green gradient accents matching FreeGo branding
- **Responsive Design**: Optimized for mobile devices with smooth animations

### 📊 Charts & Analytics
- **Temperature Trends**: Interactive line charts showing temperature history
- **Humidity Monitoring**: Visual representation of humidity levels over time
- **Time Range Selection**: View data for 1 hour, 24 hours, 7 days, or 30 days
- **Data Visualization**: Powered by FL Chart for smooth, interactive graphs

### 📹 Live Monitor
- **WebSocket Connection**: Real-time communication with Raspberry Pi
- **Sensor Data**: Live temperature, humidity, and battery readings
- **Connection Status**: Clear indicators for connected/disconnected states
- **Historical Data**: Access to stored sensor readings from Firestore

### 🔔 Alerts & Notifications
- **Smart Alerts**: Temperature threshold warnings, low battery alerts, door open alerts
- **Real-time Notifications**: Instant push notifications for critical events
- **Alert History**: Browse and manage past notifications
- **Swipe to Dismiss**: Easy gesture-based alert management

### ⚙️ Settings
- **Alert Thresholds**: Configure temperature and humidity limits with +/- buttons
- **Door Open Timer**: Set maximum door open duration
- **Device Information**: View device name, model, firmware version, and serial number
- **WebSocket Configuration**: Manage Raspberry Pi connection settings
- **Notifications Toggle**: Enable/disable alert notifications
- **Dark Mode**: Toggle between light and dark themes (coming soon)

### 🔐 Authentication
- **Firebase Auth**: Secure email/password authentication
- **User Registration**: Easy sign-up process with email verification
- **Auto-login**: Persistent sessions for returning users
- **Sign Out**: Secure logout functionality

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK 3.7.2 or higher
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hayderjamli/freego_dashboard.git
   cd freego_dashboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - The project is already configured for Firebase project `freego-edb69`
   - Firebase configuration files are in place:
     - `lib/firebase_options.dart`
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants and models
│   │   └── models.dart     # Data models (DashboardData, ThresholdSettings, etc.)
│   └── theme/              # Theme configuration
│       ├── app_colors.dart # Color palette
│       └── app_theme.dart  # Light and dark theme definitions
├── features/
│   ├── alerts/             # Alerts and notifications feature
│   │   └── alerts_page.dart
│   ├── charts/             # Data visualization feature
│   │   └── charts_page.dart
│   ├── dashboard/          # Main dashboard feature
│   │   └── presentation/
│   │       └── widgets/
│   │           └── dashboard_home_page.dart
│   └── settings/           # Settings and configuration
│       └── settings_page_new.dart
├── services/
│   └── firestore_service.dart   # Firestore database operations
├── shared/
│   └── widgets/
│       └── dashboard_widgets.dart # Reusable UI components
├── auth_service.dart       # Firebase Authentication service
├── firebase_options.dart   # Firebase configuration
├── login_page.dart         # Login screen
├── signup_page.dart        # Registration screen
├── welcome_page.dart       # Welcome/landing screen
├── notifications_page.dart # Notifications list
├── notification_service.dart # Notification management
├── pi_monitor_page.dart    # Live monitoring screen
└── main.dart               # App entry point
```

---

## 🎨 Design System

### Color Palette
- **Primary**: Green (`#27AE60`) - Main brand color
- **Secondary**: Light Green (`#6FCF97`) - Accents
- **Success**: Green gradient
- **Warning**: Yellow (`#F2C94C`)
- **Danger**: Red (`#EB5757`)
- **Background**: Light Gray (`#F7F9FC`)
- **Text**: Dark Gray (`#1A1A1A`)

### Typography
- **Headings**: Bold, clear hierarchy
- **Body Text**: Readable, comfortable line height
- **Numbers**: Large, prominent display for metrics

---

## 🔧 Configuration

### WebSocket Connection
Update the WebSocket endpoint in Settings page to connect to your Raspberry Pi:
```
ws://192.168.x.x:8000
```

### Alert Thresholds (Adjustable in Settings)
- **Temperature Range**: Default -18°C to -8°C
- **Humidity Range**: Default 30% to 70%
- **Door Open Max**: Default 5 minutes

---

## 🐍 Raspberry Pi Server

The project includes a Python WebSocket server (`iot_stream_server.py`) for Raspberry Pi that:
- Streams sensor data (DHT22 temperature & humidity)
- Provides camera feed (PiCamera2)
- Sends real-time updates to the Flutter app

### Server Requirements
- Python 3.7+
- Required packages: `websockets`, `opencv-python`, `picamera2`, `adafruit-dht`
- Install: `pip install -r requirements.txt`

### Running the Server
```bash
python iot_stream_server.py
```

---

## 📦 Dependencies

### Main Packages
- `firebase_core: ^4.2.0` - Firebase SDK core
- `firebase_auth: ^6.1.1` - Authentication
- `cloud_firestore: ^6.0.3` - Cloud database
- `fl_chart: ^0.68.0` - Charts and graphs
- `web_socket_channel: ^2.4.0` - WebSocket communication
- `cupertino_icons: ^1.0.8` - iOS-style icons

---

## 🌐 Firebase Configuration

### Firestore Collections
- **users**: User profiles and settings
- **devices**: Device information and metadata
- **sensorData**: Historical sensor readings
- **alerts**: Alert history and notifications

### Authentication
- Email/Password authentication enabled
- User registration with profile creation
- Automatic Firestore document creation for new users

---

## 🧪 Testing

Run tests with:
```bash
flutter test
```

---

## 📱 Supported Platforms

- ✅ Android (5.0+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Safari, Firefox)
- ✅ Windows (Desktop)
- ✅ macOS (Desktop)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is part of the FreeGo Smart Solar Freezer initiative.

---

## 👨‍💻 Author

**Hayder Jamli**
- GitHub: [@Hayderjamli](https://github.com/Hayderjamli)
- Project: FreeGo Dashboard

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- FL Chart for beautiful visualizations
- The open-source community

---

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

**Made with ❤️ for sustainable cold storage solutions**
