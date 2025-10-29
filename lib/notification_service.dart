import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AlertNotification> _notifications = [];
  
  List<AlertNotification> get notifications => _notifications;

  void checkThresholds({
    required double currentTemp,
    required double currentHumidity,
    required bool isDoorOpen,
    required int doorOpenMinutes,
    required ThresholdSettings settings,
  }) {
    if (!settings.notificationsEnabled) return;

    final now = DateTime.now();

    // Temperature checks
    if (currentTemp < settings.minTemperature) {
      _addNotification(AlertNotification(
        id: 'temp_low_${now.millisecondsSinceEpoch}',
        type: AlertType.temperatureLow,
        title: 'LOW TEMPERATURE ALERT',
        message: 'Temperature dropped to ${currentTemp.toStringAsFixed(1)}°C (Min: ${settings.minTemperature.toStringAsFixed(1)}°C)',
        timestamp: now,
        value: currentTemp,
        threshold: settings.minTemperature,
      ));
    }

    if (currentTemp > settings.maxTemperature) {
      _addNotification(AlertNotification(
        id: 'temp_high_${now.millisecondsSinceEpoch}',
        type: AlertType.temperatureHigh,
        title: 'HIGH TEMPERATURE ALERT',
        message: 'Temperature rose to ${currentTemp.toStringAsFixed(1)}°C (Max: ${settings.maxTemperature.toStringAsFixed(1)}°C)',
        timestamp: now,
        value: currentTemp,
        threshold: settings.maxTemperature,
      ));
    }

    // Humidity checks
    if (currentHumidity < settings.minHumidity) {
      _addNotification(AlertNotification(
        id: 'humidity_low_${now.millisecondsSinceEpoch}',
        type: AlertType.humidityLow,
        title: 'LOW HUMIDITY ALERT',
        message: 'Humidity dropped to ${currentHumidity.toStringAsFixed(0)}% (Min: ${settings.minHumidity.toStringAsFixed(0)}%)',
        timestamp: now,
        value: currentHumidity,
        threshold: settings.minHumidity,
      ));
    }

    if (currentHumidity > settings.maxHumidity) {
      _addNotification(AlertNotification(
        id: 'humidity_high_${now.millisecondsSinceEpoch}',
        type: AlertType.humidityHigh,
        title: 'HIGH HUMIDITY ALERT',
        message: 'Humidity rose to ${currentHumidity.toStringAsFixed(0)}% (Max: ${settings.maxHumidity.toStringAsFixed(0)}%)',
        timestamp: now,
        value: currentHumidity,
        threshold: settings.maxHumidity,
      ));
    }

    // Door open duration check
    if (isDoorOpen && doorOpenMinutes > settings.maxDoorOpenMinutes) {
      _addNotification(AlertNotification(
        id: 'door_open_${now.millisecondsSinceEpoch}',
        type: AlertType.doorOpenTooLong,
        title: 'DOOR OPEN ALERT',
        message: 'Door has been open for $doorOpenMinutes minutes (Max: ${settings.maxDoorOpenMinutes} min)',
        timestamp: now,
        value: doorOpenMinutes.toDouble(),
        threshold: settings.maxDoorOpenMinutes.toDouble(),
      ));
    }
  }

  void _addNotification(AlertNotification notification) {
    // Check if similar notification exists in last 5 minutes
    final recentSimilar = _notifications.where((n) {
      return n.type == notification.type &&
          n.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5)));
    });

    if (recentSimilar.isEmpty) {
      _notifications.insert(0, notification);
      // Keep only last 50 notifications
      if (_notifications.length > 50) {
        _notifications.removeLast();
      }
    }
  }

  void clearNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    _notifications.clear();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
  }
}

enum AlertType {
  temperatureLow,
  temperatureHigh,
  humidityLow,
  humidityHigh,
  doorOpenTooLong,
}

class AlertNotification {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final double value;
  final double threshold;
  bool isRead;

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

  IconData get icon {
    switch (type) {
      case AlertType.temperatureLow:
        return Icons.ac_unit_rounded;
      case AlertType.temperatureHigh:
        return Icons.local_fire_department_rounded;
      case AlertType.humidityLow:
        return Icons.dry_rounded;
      case AlertType.humidityHigh:
        return Icons.water_rounded;
      case AlertType.doorOpenTooLong:
        return Icons.sensor_door_rounded;
    }
  }

  Color get color {
    switch (type) {
      case AlertType.temperatureLow:
        return AppPalette.electricBlue;
      case AlertType.temperatureHigh:
        return AppPalette.vibrantOrange;
      case AlertType.humidityLow:
        return AppPalette.energyYellow;
      case AlertType.humidityHigh:
        return AppPalette.sportGreen;
      case AlertType.doorOpenTooLong:
        return AppPalette.neonPink;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
