import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'main.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppPalette.energyGradient.createShader(bounds),
          child: const Text(
            'NOTIFICATIONS',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              onPressed: () {
                setState(() {
                  _notificationService.markAllAsRead();
                });
              },
              tooltip: 'Mark all as read',
              style: IconButton.styleFrom(
                backgroundColor: AppPalette.electricBlue.withOpacity(0.2),
                foregroundColor: AppPalette.electricBlue,
              ),
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppPalette.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppPalette.neonPink.withOpacity(0.5), width: 2),
                    ),
                    title: const Text(
                      'CLEAR ALL NOTIFICATIONS?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    content: const Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppPalette.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _notificationService.clearAll();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'CLEAR ALL',
                          style: TextStyle(
                            color: AppPalette.neonPink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Clear all',
              style: IconButton.styleFrom(
                backgroundColor: AppPalette.neonPink.withOpacity(0.2),
                foregroundColor: AppPalette.neonPink,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppPalette.backgroundGradient),
        child: SafeArea(
          child: notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification, index);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppPalette.purpleGradient.colors.isNotEmpty
                  ? LinearGradient(
                      colors: AppPalette.purpleGradient.colors.map((c) => c.withOpacity(0.3)).toList(),
                    )
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.electricBlue.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: AppPalette.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NO ALERTS YET',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ll be notified when thresholds are exceeded',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPalette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AlertNotification notification, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          setState(() {
            _notificationService.clearNotification(notification.id);
          });
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppPalette.neonPink, AppPalette.vibrantOrange],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _notificationService.markAsRead(notification.id);
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  notification.color.withOpacity(notification.isRead ? 0.1 : 0.2),
                  notification.color.withOpacity(notification.isRead ? 0.05 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: notification.isRead
                    ? notification.color.withOpacity(0.3)
                    : notification.color.withOpacity(0.6),
                width: notification.isRead ? 1.5 : 2.5,
              ),
              boxShadow: notification.isRead
                  ? null
                  : [
                      BoxShadow(
                        color: notification.color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        notification.color,
                        notification.color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: notification.color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    notification.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: notification.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: notification.color.withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.textSecondary,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppPalette.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.timeAgo,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppPalette.textMuted,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
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
      ),
    );
  }
}
