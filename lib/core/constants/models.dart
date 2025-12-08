import 'package:flutter/material.dart';

/// Data models for the FreeGo Dashboard.
/// 
/// Contains sensor readings, door status, and dashboard data classes.

/// Represents a single sensor reading with timestamp.
class SensorReading {
  const SensorReading({
    required this.label,
    required this.value,
    this.timestamp,
  });

  final String label;
  final double value;
  final DateTime? timestamp;

  SensorReading copyWith({
    String? label,
    double? value,
    DateTime? timestamp,
  }) {
    return SensorReading(
      label: label ?? this.label,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Door cycle statistics for a time period.
class DoorCycleStat {
  const DoorCycleStat({
    required this.label,
    required this.openings,
    required this.closures,
  });

  final String label;
  final int openings;
  final int closures;
}

/// Door status enumeration.
enum DoorStatus { open, closed }

/// Alert types for threshold notifications.
enum AlertType {
  temperatureLow,
  temperatureHigh,
  humidityLow,
  humidityHigh,
  doorOpenTooLong,
  lowBattery,
  connectionLost,
}

/// Alert notification model.
class AlertNotification {
  AlertNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.value,
    required this.threshold,
    this.isRead = false,
  });

  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final double value;
  final double threshold;
  bool isRead;

  /// Human-readable time ago string.
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Get color based on alert type.
  Color get color {
    switch (type) {
      case AlertType.temperatureHigh:
      case AlertType.doorOpenTooLong:
        return const Color(0xFFEB5757);
      case AlertType.temperatureLow:
        return const Color(0xFF56CCF2);
      case AlertType.humidityHigh:
        return const Color(0xFF2D9CDB);
      case AlertType.humidityLow:
        return const Color(0xFFF2C94C);
      case AlertType.lowBattery:
        return const Color(0xFFF2994A);
      case AlertType.connectionLost:
        return const Color(0xFF828282);
    }
  }

  /// Get icon based on alert type.
  IconData get icon {
    switch (type) {
      case AlertType.temperatureHigh:
        return Icons.thermostat;
      case AlertType.temperatureLow:
        return Icons.ac_unit;
      case AlertType.humidityHigh:
      case AlertType.humidityLow:
        return Icons.water_drop;
      case AlertType.doorOpenTooLong:
        return Icons.door_front_door;
      case AlertType.lowBattery:
        return Icons.battery_alert;
      case AlertType.connectionLost:
        return Icons.wifi_off;
    }
  }
}

/// Sensor log entry for the logs page.
class SensorLogEntry {
  const SensorLogEntry({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    this.doorStatus,
    this.batteryLevel,
    this.solarInput,
  });

  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final DoorStatus? doorStatus;
  final double? batteryLevel;
  final double? solarInput;

  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    return '$day/$month/$year';
  }
}

/// Complete dashboard data snapshot.
class DashboardData {
  const DashboardData({
    required this.temperatureReadings,
    required this.humidityReadings,
    required this.doorCycles,
    required this.doorStatus,
    required this.lastUpdated,
    this.batteryLevel,
    this.solarInput,
    this.isConnected = false,
  });

  final List<SensorReading> temperatureReadings;
  final List<SensorReading> humidityReadings;
  final List<DoorCycleStat> doorCycles;
  final DoorStatus doorStatus;
  final DateTime lastUpdated;
  final double? batteryLevel;
  final double? solarInput;
  final bool isConnected;

  /// Latest temperature value.
  double? get latestTemperature =>
      temperatureReadings.isNotEmpty ? temperatureReadings.last.value : null;

  /// Latest humidity value.
  double? get latestHumidity =>
      humidityReadings.isNotEmpty ? humidityReadings.last.value : null;

  /// Minimum temperature from readings.
  double? get minTemperature => temperatureReadings.isNotEmpty
      ? temperatureReadings.map((r) => r.value).reduce((a, b) => a < b ? a : b)
      : null;

  /// Maximum temperature from readings.
  double? get maxTemperature => temperatureReadings.isNotEmpty
      ? temperatureReadings.map((r) => r.value).reduce((a, b) => a > b ? a : b)
      : null;

  /// Minimum humidity from readings.
  double? get minHumidity => humidityReadings.isNotEmpty
      ? humidityReadings.map((r) => r.value).reduce((a, b) => a < b ? a : b)
      : null;

  /// Maximum humidity from readings.
  double? get maxHumidity => humidityReadings.isNotEmpty
      ? humidityReadings.map((r) => r.value).reduce((a, b) => a > b ? a : b)
      : null;

  /// Formatted last updated time.
  String get lastUpdatedLabel =>
      '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}';

  /// Create a copy with updated values.
  DashboardData copyWith({
    List<SensorReading>? temperatureReadings,
    List<SensorReading>? humidityReadings,
    List<DoorCycleStat>? doorCycles,
    DoorStatus? doorStatus,
    DateTime? lastUpdated,
    double? batteryLevel,
    double? solarInput,
    bool? isConnected,
  }) {
    return DashboardData(
      temperatureReadings: temperatureReadings ?? this.temperatureReadings,
      humidityReadings: humidityReadings ?? this.humidityReadings,
      doorCycles: doorCycles ?? this.doorCycles,
      doorStatus: doorStatus ?? this.doorStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      solarInput: solarInput ?? this.solarInput,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  /// Sample data for development and testing.
  static DashboardData sample() {
    return DashboardData(
      temperatureReadings: const [
        SensorReading(label: '00h', value: 19.5),
        SensorReading(label: '04h', value: 18.8),
        SensorReading(label: '08h', value: 20.2),
        SensorReading(label: '12h', value: 23.5),
        SensorReading(label: '16h', value: 24.2),
        SensorReading(label: '20h', value: 22.4),
        SensorReading(label: '24h', value: 20.1),
      ],
      humidityReadings: const [
        SensorReading(label: '00h', value: 62),
        SensorReading(label: '04h', value: 65),
        SensorReading(label: '08h', value: 58),
        SensorReading(label: '12h', value: 54),
        SensorReading(label: '16h', value: 50),
        SensorReading(label: '20h', value: 55),
        SensorReading(label: '24h', value: 60),
      ],
      doorCycles: const [
        DoorCycleStat(label: 'Morning', openings: 5, closures: 5),
        DoorCycleStat(label: 'Noon', openings: 7, closures: 6),
        DoorCycleStat(label: 'Afternoon', openings: 4, closures: 5),
        DoorCycleStat(label: 'Evening', openings: 6, closures: 6),
      ],
      doorStatus: DoorStatus.closed,
      lastUpdated: DateTime.now(),
      batteryLevel: 78.0,
      solarInput: 1.0,
      isConnected: true,
    );
  }
}

/// Threshold settings for alerts.
class ThresholdSettings {
  ThresholdSettings({
    this.minTemperature = -18.0,
    this.maxTemperature = -8.0,
    this.minHumidity = 30.0,
    this.maxHumidity = 70.0,
    this.maxDoorOpenMinutes = 5,
    this.lowBatteryThreshold = 20.0,
    this.notificationsEnabled = true,
  });

  double minTemperature;
  double maxTemperature;
  double minHumidity;
  double maxHumidity;
  int maxDoorOpenMinutes;
  double lowBatteryThreshold;
  bool notificationsEnabled;

  ThresholdSettings copyWith({
    double? minTemperature,
    double? maxTemperature,
    double? minHumidity,
    double? maxHumidity,
    int? maxDoorOpenMinutes,
    double? lowBatteryThreshold,
    bool? notificationsEnabled,
  }) {
    return ThresholdSettings(
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
      maxDoorOpenMinutes: maxDoorOpenMinutes ?? this.maxDoorOpenMinutes,
      lowBatteryThreshold: lowBatteryThreshold ?? this.lowBatteryThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Device information model.
class DeviceInfo {
  const DeviceInfo({
    required this.name,
    required this.model,
    required this.firmwareVersion,
    required this.serialNumber,
    this.lastConnected,
    this.ipAddress,
  });

  final String name;
  final String model;
  final String firmwareVersion;
  final String serialNumber;
  final DateTime? lastConnected;
  final String? ipAddress;

  static DeviceInfo defaultDevice() {
    return const DeviceInfo(
      name: 'FreeGo ',
      model: 'FG-001',
      firmwareVersion: '1.0.0',
      serialNumber: 'FG2024001',
      ipAddress: '192.168.137.104',
    );
  }
}
