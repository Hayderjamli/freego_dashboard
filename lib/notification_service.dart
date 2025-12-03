import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/core/theme/app_colors.dart';
import 'package:mobile_app_dashboard/core/constants/models.dart';

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
        title: 'Low Temperature Alert',
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
        title: 'High Temperature Alert',
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
        title: 'Low Humidity Alert',
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
        title: 'High Humidity Alert',
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
        title: 'Door Open Alert',
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
