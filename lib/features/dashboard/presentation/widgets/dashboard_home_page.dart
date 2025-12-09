import 'package:flutter/material.dart';
import 'package:freego_dashboard/notifications_page.dart';
import 'package:freego_dashboard/notification_service.dart';
import 'package:freego_dashboard/core/theme/app_colors.dart';
import 'package:freego_dashboard/core/constants/models.dart';
import 'package:freego_dashboard/shared/widgets/dashboard_widgets.dart';

/// Dashboard Home Page - Main dashboard with big metric cards
/// 
/// Displays temperature, humidity, battery/solar, and real-time status.
class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({
    super.key,
    required this.data,
    required this.settings,
  });

  final DashboardData data;
  final ThresholdSettings settings;

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Content
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverToBoxAdapter(
                child: _buildContent(context, data, isTablet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo and Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/freego_logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    /*Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      /*children: [
                        Text(
                          'FreeGo',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Smart Solar Freezer',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],*/
                    ),*/
                  ],
                ),
              ],
            ),
          ),
          
          // Status Indicator
          StatusIndicator(
            label: widget.data.isConnected ? 'LIVE' : 'OFFLINE',
            isOnline: widget.data.isConnected,
            showPulse: true,
          ),
          
          const SizedBox(width: 8),
          
          // Notifications Button
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  ).then((_) => setState(() {}));
                },
                icon: const Icon(Icons.notifications_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
              if (_notificationService.unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationService.unreadCount > 9
                          ? '9+'
                          : '${_notificationService.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardData data, bool isTablet) {
    final latestTemp = data.latestTemperature;
    final latestHumidity = data.latestHumidity;
    final batteryLevel = data.batteryLevel ?? 0;
    final solarInput = data.solarInput ?? 0;
    
    if (isTablet) {
      return _buildTabletLayout(context, data, latestTemp, latestHumidity, batteryLevel, solarInput);
    }
    return _buildMobileLayout(context, data, latestTemp, latestHumidity, batteryLevel, solarInput);
  }

  Widget _buildMobileLayout(
    BuildContext context,
    DashboardData data,
    double? latestTemp,
    double? latestHumidity,
    double batteryLevel,
    double solarInput,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildDeviceStatusCard(context, data),
        
        const SizedBox(height: 16),
        
        // Section Header
        SectionHeader(
          title: 'Key Metrics',
          subtitle: 'Real-time sensor data',
        ),
        
        const SizedBox(height: 12),
        
        // Temperature Card (Large)
        _buildTemperatureCard(latestTemp, data),
        
        const SizedBox(height: 12),
        
        // Humidity Card (Large)
        _buildHumidityCard(latestHumidity, data),
        
        const SizedBox(height: 16),
        
        // Power Section
        SectionHeader(
          title: 'Power Status',
          subtitle: 'Battery and solar input',
        ),
        
        const SizedBox(height: 12),
        
        // Battery and Solar Cards (Side by side)
        Row(
          children: [
            Expanded(child: _buildBatteryCard(batteryLevel)),
            const SizedBox(width: 12),
            Expanded(child: _buildSolarCard(solarInput)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Door Status
        _buildDoorStatusCard(context, data),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    DashboardData data,
    double? latestTemp,
    double? latestHumidity,
    double batteryLevel,
    double solarInput,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildDeviceStatusCard(context, data),
        
        const SizedBox(height: 24),
        
        SectionHeader(
          title: 'Key Metrics',
          subtitle: 'Real-time environmental and power data',
        ),
        
        const SizedBox(height: 16),
        
        // Main metrics grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Temperature & Humidity
            Expanded(
              child: Column(
                children: [
                  _buildTemperatureCard(latestTemp, data),
                  const SizedBox(height: 12),
                  _buildHumidityCard(latestHumidity, data),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right column - Battery, Solar, Door
            Expanded(
              child: Column(
                children: [
                  _buildBatteryCard(batteryLevel),
                  const SizedBox(height: 12),
                  _buildSolarCard(solarInput),
                  const SizedBox(height: 12),
                  _buildDoorStatusCard(context, data),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceStatusCard(BuildContext context, DashboardData data) {
    return DashboardCard(
      gradient: AppColors.successGradient,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.device_thermostat_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FreeGo ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: data.isConnected ? Colors.white : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          data.isConnected ? 'Connected' : 'Disconnected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last sync: ${data.lastUpdatedLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCard(double? value, DashboardData data) {
    final displayValue = value?.toStringAsFixed(1) ?? '--';
    final hasRange = data.minTemperature != null && data.maxTemperature != null;
    
    Color tempColor = AppColors.secondary;
    if (value != null) {
      if (value < -15) tempColor = AppColors.tempCold;
      else if (value > -5) tempColor = AppColors.tempHot;
      else if (value > -10) tempColor = AppColors.tempWarm;
    }
    
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tempColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.thermostat_rounded,
                  color: tempColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Temperature',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              StatusIndicator(
                label: 'LIVE',
                isOnline: value != null,
                size: StatusIndicatorSize.small,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayValue,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '°C',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (hasRange) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.minTemperature!.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tempColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tempColor,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.maxTemperature!.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tempColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Waiting for data...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHumidityCard(double? value, DashboardData data) {
    final displayValue = value?.toStringAsFixed(0) ?? '--';
    final hasRange = data.minHumidity != null && data.maxHumidity != null;
    
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.chartHumidity.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.chartHumidity,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Humidity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              StatusIndicator(
                label: 'LIVE',
                isOnline: value != null,
                size: StatusIndicatorSize.small,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayValue,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (hasRange) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.minHumidity!.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.chartHumidity.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.chartHumidity,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data.maxHumidity!.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.chartHumidity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Waiting for data...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatteryCard(double level) {
    Color batteryColor = AppColors.batteryFull;
    IconData batteryIcon = Icons.battery_full_rounded;
    
    if (level < 20) {
      batteryColor = AppColors.batteryLow;
      batteryIcon = Icons.battery_alert_rounded;
    } else if (level < 50) {
      batteryColor = AppColors.batteryMedium;
      batteryIcon = Icons.battery_4_bar_rounded;
    }
    
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: batteryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(batteryIcon, color: batteryColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Battery',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '78%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.78,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolarCard(double input) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.chartSolar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.solar_power_rounded,
                  color: AppColors.chartSolar,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Solar',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1W',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                input > 0 ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                size: 14,
                color: input > 0 ? AppColors.chartSolar : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Charging',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoorStatusCard(BuildContext context, DashboardData data) {
    final isOpen = data.doorStatus == DoorStatus.open;
    final statusColor = isOpen ? AppColors.warning : AppColors.secondary;
    
    return DashboardCard(
      borderColor: statusColor.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOpen ? Icons.door_front_door : Icons.door_sliding_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Door Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOpen ? 'OPEN' : 'CLOSED',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOpen ? 'Alert' : 'Secure',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
