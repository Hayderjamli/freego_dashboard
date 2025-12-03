import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/core/theme/app_colors.dart';
import 'package:mobile_app_dashboard/core/constants/models.dart';
import 'package:mobile_app_dashboard/shared/widgets/dashboard_widgets.dart';
import 'package:mobile_app_dashboard/notification_service.dart';

/// Alerts Page - Display warnings and alerts
/// 
/// Shows high temp, low battery, communication failure alerts.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final alerts = _notificationService.notifications;
    final unreadAlerts = alerts.where((a) => !a.isRead).toList();
    final readAlerts = alerts.where((a) => a.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, alerts.length),
            ),
            
            // Content
            if (alerts.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (unreadAlerts.isNotEmpty) ...[
                      _buildSectionTitle('New Alerts', unreadAlerts.length),
                      const SizedBox(height: 12),
                      ...unreadAlerts.map((alert) => _buildAlertCard(alert)),
                      const SizedBox(height: 24),
                    ],
                    if (readAlerts.isNotEmpty) ...[
                      _buildSectionTitle('Past Alerts', readAlerts.length),
                      const SizedBox(height: 12),
                      ...readAlerts.map((alert) => _buildAlertCard(alert)),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int alertCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerts',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$alertCount notifications',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (alertCount > 0) ...[
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _notificationService.markAllAsRead();
                });
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark all read'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _showClearDialog();
              },
              icon: const Icon(Icons.delete_outline_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                foregroundColor: AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Clear!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No alerts at the moment.\nYour freezer is running smoothly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertNotification alert) {
    final alertConfig = _getAlertConfig(alert.type);
    
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _notificationService.clearNotification(alert.id);
        });
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _notificationService.markAsRead(alert.id);
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alert.isRead
                  ? Colors.transparent
                  : alertConfig.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alertConfig.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  alertConfig.icon,
                  color: alertConfig.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: alertConfig.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alert.timeAgo,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _AlertConfig _getAlertConfig(AlertType type) {
    switch (type) {
      case AlertType.temperatureLow:
        return _AlertConfig(
          icon: Icons.ac_unit_rounded,
          color: AppColors.info,
        );
      case AlertType.temperatureHigh:
        return _AlertConfig(
          icon: Icons.local_fire_department_rounded,
          color: AppColors.danger,
        );
      case AlertType.humidityLow:
        return _AlertConfig(
          icon: Icons.water_drop_outlined,
          color: AppColors.warning,
        );
      case AlertType.humidityHigh:
        return _AlertConfig(
          icon: Icons.water_rounded,
          color: AppColors.info,
        );
      case AlertType.doorOpenTooLong:
        return _AlertConfig(
          icon: Icons.door_front_door_rounded,
          color: AppColors.warning,
        );
      case AlertType.lowBattery:
        return _AlertConfig(
          icon: Icons.battery_alert_rounded,
          color: AppColors.danger,
        );
      case AlertType.connectionLost:
        return _AlertConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.danger,
        );
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear All Alerts?'),
        content: const Text(
          'This will permanently delete all notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notificationService.clearAll();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _AlertConfig {
  final IconData icon;
  final Color color;

  _AlertConfig({required this.icon, required this.color});
}
