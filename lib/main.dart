import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/welcome_page.dart';
import 'package:mobile_app_dashboard/notification_service.dart';
import 'package:mobile_app_dashboard/pi_monitor_page.dart';
import 'package:mobile_app_dashboard/features/dashboard/presentation/widgets/dashboard_home_page.dart';
import 'package:mobile_app_dashboard/features/charts/charts_page.dart';
import 'package:mobile_app_dashboard/features/alerts/alerts_page.dart';
import 'package:mobile_app_dashboard/features/settings/settings_page_new.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/models.dart';
import 'firebase_options.dart';

// ============================================================================
// LEGACY AppPalette - Kept for backward compatibility with existing pages
// New pages should use AppColors from core/theme/app_colors.dart
// ============================================================================
class AppPalette {
  const AppPalette._();

  // Mapped to new color scheme for consistency
  static const Color darkBg = Color(0xFFF7F9FC); // Light background
  static const Color deepPurple = Color(0xFF2D9CDB); // Primary blue
  static const Color richPurple = Color(0xFF2D9CDB);
  static const Color electricBlue = Color(0xFF2D9CDB); // Primary
  static const Color neonPink = Color(0xFFEB5757); // Danger
  static const Color vibrantOrange = Color(0xFFF2C94C); // Warning/Accent
  static const Color energyYellow = Color(0xFFF2C94C);
  static const Color sportGreen = Color(0xFF27AE60); // Secondary/Success
  static const Color cardDark = Color(0xFFFFFFFF); // Card surface
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF7F9FC), Color(0xFFEDF2F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sportGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF6FCF97)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF2D9CDB), Color(0xFF56CCF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeGo Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const WelcomePage(),
    );
  }
}

// ============================================================================
// HomePage - Main Navigation Hub
// ============================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late DashboardData data;
  final ThresholdSettings settings = ThresholdSettings();
  final NotificationService notificationService = NotificationService();
  
  // Sensor data lists to track incoming data
  final List<SensorReading> temperatureReadings = [];
  final List<SensorReading> humidityReadings = [];

  @override
  void initState() {
    super.initState();
    data = DashboardData(
      temperatureReadings: temperatureReadings,
      humidityReadings: humidityReadings,
      doorCycles: const [
        DoorCycleStat(label: 'Morning', openings: 5, closures: 5),
        DoorCycleStat(label: 'Noon', openings: 7, closures: 6),
        DoorCycleStat(label: 'Afternoon', openings: 4, closures: 5),
        DoorCycleStat(label: 'Evening', openings: 6, closures: 6),
      ],
      doorStatus: DoorStatus.closed,
      lastUpdated: DateTime.now(),
    );
    // Check thresholds periodically
    Future.delayed(const Duration(seconds: 5), () {
      _checkThresholds();
    });
  }

  void _addSensorReading(double? temperature, double? humidity) {
    if (!mounted) return;

    setState(() {
      // Add temperature reading (keep last 7 readings for chart)
      if (temperature != null) {
        final tempLabel = 'T${temperatureReadings.length}';
        temperatureReadings.add(
          SensorReading(label: tempLabel, value: temperature),
        );
        if (temperatureReadings.length > 7) {
          temperatureReadings.removeAt(0);
        }
      }

      // Add humidity reading (keep last 7 readings for chart)
      if (humidity != null) {
        final humLabel = 'H${humidityReadings.length}';
        humidityReadings.add(SensorReading(label: humLabel, value: humidity));
        if (humidityReadings.length > 7) {
          humidityReadings.removeAt(0);
        }
      }

      // Update the data object
      data = DashboardData(
        temperatureReadings: temperatureReadings,
        humidityReadings: humidityReadings,
        doorCycles: data.doorCycles,
        doorStatus: data.doorStatus,
        lastUpdated: DateTime.now(),
      );
    });
  }

  void _checkThresholds() {
    if (!mounted) return;
    
    final latestTemp = data.temperatureReadings.isNotEmpty 
        ? data.temperatureReadings.last.value 
        : 20.0;
    final latestHumidity = data.humidityReadings.isNotEmpty 
        ? data.humidityReadings.last.value 
        : 50.0;
    final isDoorOpen = data.doorStatus == DoorStatus.open;

    notificationService.checkThresholds(
      currentTemp: latestTemp,
      currentHumidity: latestHumidity,
      isDoorOpen: isDoorOpen,
      doorOpenMinutes: 6,
      settings: settings,
    );

    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          DashboardHomePage(data: data, settings: settings),
          ChartsPage(data: data),
          PiMonitorPage(onSensor: _addSensorReading),
          AlertsPage(),
          SettingsPageNew(settings: settings),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
              _buildNavItem(1, Icons.show_chart_rounded, Icons.show_chart_outlined, 'Charts'),
              _buildNavItem(2, Icons.videocam_rounded, Icons.videocam_outlined, 'Live'),
              _buildNavItem(3, Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts', badge: notificationService.unreadCount),
              _buildNavItem(4, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {int badge = 0}) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -4,
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
                        badge > 9 ? '9+' : '$badge',
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.data, required this.settings});
  final DashboardData data;
  final ThresholdSettings settings;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final latestTemperature =
        data.temperatureReadings.isNotEmpty
            ? data.temperatureReadings.last.value
            : null;
    final minTemperature =
        data.temperatureReadings.isNotEmpty
            ? data.temperatureReadings
                .map((reading) => reading.value)
                .reduce((a, b) => a < b ? a : b)
            : null;
    final maxTemperature =
        data.temperatureReadings.isNotEmpty
            ? data.temperatureReadings
                .map((reading) => reading.value)
                .reduce((a, b) => a > b ? a : b)
            : null;

    final latestHumidity =
        data.humidityReadings.isNotEmpty
            ? data.humidityReadings.last.value
            : null;
    final minHumidity =
        data.humidityReadings.isNotEmpty
            ? data.humidityReadings
                .map((reading) => reading.value)
                .reduce((a, b) => a < b ? a : b)
            : null;
    final maxHumidity =
        data.humidityReadings.isNotEmpty
            ? data.humidityReadings
                .map((reading) => reading.value)
                .reduce((a, b) => a > b ? a : b)
            : null;

    final totalDoorCycles = data.doorCycles.fold<int>(
      0,
      (sum, stat) => sum + stat.openings + stat.closures,
    );
    final statusText =
        data.doorStatus == DoorStatus.open ? 'Ouverte' : 'Fermée';
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("OVERVIEW"),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  ).then((_) => setState(() {}));
                },
                icon: const Icon(Icons.notifications_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: AppPalette.neonPink.withOpacity(0.2),
                  foregroundColor: AppPalette.neonPink,
                ),
              ),
              if (_notificationService.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppPalette.neonPink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.neonPink.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
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
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppPalette.electricBlue.withOpacity(0.2),
              foregroundColor: AppPalette.electricBlue,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth > 1200
                    ? 3
                    : constraints.maxWidth > 760
                    ? 2
                    : 1;
            final itemWidth =
                columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (columns - 1) * 18) / columns;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewHeader(lastUpdated: data.lastUpdatedLabel),
                  const SizedBox(height: 24),
                  const _SectionHeading(
                    title: 'KEY METRICS',
                    subtitle:
                        'Real-time environmental data and door activity status',
                  ),
                  const SizedBox(height: 16),
                    Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Temperature Now',
                          value:
                              latestTemperature != null
                                  ? '${latestTemperature.toStringAsFixed(1)}°C'
                                  : '--',
                          subtitle:
                              (minTemperature != null &&
                                      maxTemperature != null)
                                  ? 'Range: ${minTemperature.toStringAsFixed(1)}°C - ${maxTemperature.toStringAsFixed(1)}°C'
                                  : null,
                          icon: Icons.thermostat_rounded,
                          accent: AppPalette.energyGradient,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Humidity Level',
                          value:
                              latestHumidity != null
                                  ? '${latestHumidity.toStringAsFixed(0)}%'
                                  : '--',
                          subtitle:
                              (minHumidity != null && maxHumidity != null)
                                  ? 'Range: ${minHumidity.toStringAsFixed(0)}% - ${maxHumidity.toStringAsFixed(0)}%'
                                  : null,
                          icon: Icons.water_drop_rounded,
                          accent: AppPalette.sportGradient,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Door Status',
                          value: statusText.toUpperCase(),
                          subtitle:
                              'Last update: ${data.lastUpdatedLabel}',
                          icon: Icons.sensor_door_rounded,
                          badgeColor:
                              data.doorStatus == DoorStatus.open
                                  ? AppPalette.sportGreen
                                  : AppPalette.textMuted,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Total Activity',
                          value: '$totalDoorCycles',
                          subtitle: 'Door cycles today',
                          icon: Icons.autorenew_rounded,
                          accent: AppPalette.purpleGradient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.data});

  final DashboardData data;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedRange = '24h';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const FreeGoLogo(size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth > 1200
                      ? 3
                      : constraints.maxWidth > 820
                      ? 2
                      : 1;
              final itemWidth =
                  columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - (columns - 1) * 20) / columns;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeading(
                      title: 'Analyses détaillées',
                      subtitle:
                          'Visualisez l’évolution des relevés et l’activité de la porte.',
                    ),
                    const SizedBox(height: 16),
                    _TimeRangeFilter(
                      selectedRange: _selectedRange,
                      onChanged: (range) {
                        if (range != null) {
                          setState(() {
                            _selectedRange = range;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: DashboardCard(
                            title: 'Température en fonction du temps',
                            subtitle: 'Évolution sur $_selectedRange',
                            icon: Icons.thermostat,
                            contentHeight: 240,
                            child: TemperatureChart(
                              readings: widget.data.temperatureReadings,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: DashboardCard(
                            title: 'Humidité en fonction du temps',
                            subtitle: 'Évolution sur $_selectedRange',
                            icon: Icons.water_drop,
                            contentHeight: 240,
                            child: HumidityChart(
                              readings: widget.data.humidityReadings,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: DashboardCard(
                            title: 'Historique de la porte',
                            subtitle: 'Ouvertures & fermetures',
                            icon: Icons.meeting_room,
                            contentHeight: 260,
                            child: DoorUsageChart(stats: widget.data.doorCycles),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TimeRangeFilter extends StatelessWidget {
  const _TimeRangeFilter({required this.selectedRange, required this.onChanged});

  final String selectedRange;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ranges = ['1h', '24h', '7d'];
    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.purpleGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppPalette.electricBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.richPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: SegmentedButton<String>(
        segments: ranges.map((range) {
          return ButtonSegment<String>(
            value: range,
            label: Text(
              range.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          );
        }).toList(),
        selected: {selectedRange},
        onSelectionChanged: (newSelection) {
          onChanged(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppPalette.textSecondary,
          selectedForegroundColor: AppPalette.darkBg,
          selectedBackgroundColor: AppPalette.electricBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.lastUpdated});

  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: AppPalette.purpleGradient,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppPalette.electricBlue.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.richPurple.withOpacity(0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: AppPalette.electricBlue.withOpacity(0.2),
              blurRadius: 60,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimatedFreeGoLogo(size: 42),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => AppPalette.sportGradient.createShader(bounds),
              child: Text(
                'PERFORMANCE TRACKER',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Home Monitoring System',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppPalette.sportGreen.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppPalette.sportGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.sportGreen.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: AppPalette.sportGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE · Synced at $lastUpdated',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppPalette.sportGradient.createShader(bounds),
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppPalette.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class AnimatedFreeGoLogo extends StatefulWidget {
  const AnimatedFreeGoLogo({super.key, this.size = 42});

  final double size;

  @override
  State<AnimatedFreeGoLogo> createState() => _AnimatedFreeGoLogoState();
}

class _AnimatedFreeGoLogoState extends State<AnimatedFreeGoLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FreeGoLogo(size: widget.size, animationValue: _controller.value);
      },
    );
  }
}

class FreeGoLogo extends StatelessWidget {
  const FreeGoLogo({super.key, this.size = 42, this.animationValue = 0.0});

  final double size;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Color.lerp(AppPalette.electricBlue, AppPalette.sportGreen, animationValue)!,
        Color.lerp(AppPalette.sportGreen, AppPalette.energyYellow, animationValue)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textStyle = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
      color: Colors.white,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text('Free', style: textStyle),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text('Go', style: textStyle),
            ),
            Positioned(
              right: -size * 0.15,
              top: -size * 0.45,
              child: Transform.rotate(
                angle: -0.2 + (animationValue * 0.4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AppPalette.energyGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.energyYellow.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bolt,
                    size: size * 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTile extends StatefulWidget {
  const _OverviewTile({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.accent,
    this.badgeColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final LinearGradient? accent;
  final Color? badgeColor;

  @override
  State<_OverviewTile> createState() => _OverviewTileState();
}

class _OverviewTileState extends State<_OverviewTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final valueStyle = textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      color: Colors.white,
    );

    final gradient = widget.accent ?? AppPalette.purpleGradient;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: _isHovered ? 1.03 : scale,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _isHovered
                      ? AppPalette.electricBlue
                      : AppPalette.electricBlue.withOpacity(0.2),
                  width: _isHovered ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppPalette.electricBlue.withOpacity(0.4)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: _isHovered ? 35 : 25,
                    offset: Offset(0, _isHovered ? 12 : 18),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.icon != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              _isHovered
                                  ? AppPalette.electricBlue.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.15),
                              _isHovered
                                  ? AppPalette.sportGreen.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: _isHovered
                              ? [
                            BoxShadow(
                              color: AppPalette.electricBlue.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ]
                              : null,
                        ),
                        child: Icon(
                          widget.icon,
                          color: _isHovered ? AppPalette.electricBlue : AppPalette.textPrimary,
                          size: 28,
                        ),
                      ),
                    if (widget.icon != null) const SizedBox(height: 20),
                    Text(
                      widget.title.toUpperCase(),
                      style: textTheme.titleMedium?.copyWith(
                        color: AppPalette.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    widget.badgeColor != null
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.badgeColor!.withOpacity(0.25),
                            widget.badgeColor!.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.badgeColor!.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.badgeColor!.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(widget.value, style: valueStyle),
                    )
                        : ShaderMask(
                      shaderCallback: (bounds) =>
                          AppPalette.sportGradient.createShader(bounds),
                      child: Text(widget.value, style: valueStyle),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPalette.textSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.contentHeight,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double? contentHeight;
  final IconData? icon;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content =
        widget.contentHeight != null
            ? SizedBox(height: widget.contentHeight!, child: widget.child)
            : widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          gradient: AppPalette.purpleGradient,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isHovered
                ? AppPalette.electricBlue
                : AppPalette.electricBlue.withOpacity(0.3),
            width: _isHovered ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppPalette.electricBlue.withOpacity(0.4)
                  : AppPalette.richPurple.withOpacity(0.3),
              blurRadius: _isHovered ? 40 : 28,
              offset: Offset(0, _isHovered ? 16 : 24),
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.icon != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        _isHovered
                            ? AppPalette.electricBlue.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                        _isHovered
                            ? AppPalette.sportGreen.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: _isHovered
                        ? [
                      BoxShadow(
                        color: AppPalette.electricBlue.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isHovered ? AppPalette.electricBlue : AppPalette.textPrimary,
                    size: 28,
                  ),
                ),
              if (widget.icon != null) const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => AppPalette.sportGradient.createShader(bounds),
                child: Text(
                  widget.title.toUpperCase(),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSecondary,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({super.key, required this.readings});

  final List<SensorReading> readings;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(
        child: Text('Aucune donnée'),
      ); // Gracefully handle missing values.
    }

    final spots =
        readings
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList();

    final minY = readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    final maxY = readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);

    const lineGradient = LinearGradient(
      colors: [AppPalette.vibrantOrange, AppPalette.energyYellow],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}°C',
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= readings.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    readings[index].label,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        minY: (minY - 1).floorToDouble(),
        maxY: (maxY + 1).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: lineGradient,
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppPalette.energyYellow,
                  strokeWidth: 2,
                  strokeColor: AppPalette.vibrantOrange,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppPalette.vibrantOrange.withOpacity(0.4),
                  AppPalette.vibrantOrange.withOpacity(0.1),
                  AppPalette.vibrantOrange.withOpacity(0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: AppPalette.energyYellow.withOpacity(0.5),
              blurRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class HumidityChart extends StatelessWidget {
  const HumidityChart({super.key, required this.readings});

  final List<SensorReading> readings;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final spots =
        readings
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList();

    final minY = readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    final maxY = readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);

    const lineGradient = LinearGradient(
      colors: [AppPalette.electricBlue, AppPalette.sportGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= readings.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    readings[index].label,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        minY: (minY - 5).floorToDouble(),
        maxY: (maxY + 5).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: lineGradient,
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppPalette.sportGreen,
                  strokeWidth: 2,
                  strokeColor: AppPalette.electricBlue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppPalette.electricBlue.withOpacity(0.4),
                  AppPalette.sportGreen.withOpacity(0.2),
                  AppPalette.sportGreen.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: AppPalette.sportGreen.withOpacity(0.5),
              blurRadius: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class DoorUsageChart extends StatelessWidget {
  const DoorUsageChart({super.key, required this.stats});

  final List<DoorCycleStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final groups =
        stats
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barsSpace: 6,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.openings.toDouble(),
                    width: 16,
                    color: AppPalette.sportGreen,
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [AppPalette.sportGreen, AppPalette.electricBlue],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: AppPalette.sportGreen.withOpacity(0.1),
                    ),
                  ),
                  BarChartRodData(
                    toY: entry.value.closures.toDouble(),
                    width: 16,
                    color: AppPalette.neonPink,
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [AppPalette.neonPink, AppPalette.vibrantOrange],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: AppPalette.neonPink.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            )
            .toList();

    final maxY =
        stats
            .map(
              (stat) =>
                  stat.openings > stat.closures ? stat.openings : stat.closures,
            )
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                drawVerticalLine: false,
                getDrawingHorizontalLine:
                    (value) => FlLine(
                      color: Colors.white.withOpacity(0.08),
                      strokeWidth: 1,
                    ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= stats.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          stats[index].label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              groupsSpace: 12,
              barGroups: groups,
              maxY: (maxY + 1).ceilToDouble(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _LegendRow(),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendEntry(label: 'OPENINGS', color: AppPalette.sportGreen),
        SizedBox(width: 24),
        _LegendEntry(label: 'CLOSURES', color: AppPalette.neonPink),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class DoorStatusPanel extends StatelessWidget {
  const DoorStatusPanel({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final totalOpenings = data.doorCycles.fold<int>(
      0,
      (sum, stat) => sum + stat.openings,
    );
    final totalClosures = data.doorCycles.fold<int>(
      0,
      (sum, stat) => sum + stat.closures,
    );

    final isOpen = data.doorStatus == DoorStatus.open;
    final statusColor =
        isOpen ? AppPalette.sportGreen : AppPalette.textMuted;
    final statusText = isOpen ? 'Ouverte' : 'Fermée';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Porte $statusText',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusCounter(
              label: 'Ouvertures',
              value: totalOpenings,
              color: AppPalette.sportGreen,
            ),
            _StatusCounter(
              label: 'Fermetures',
              value: totalClosures,
              color: AppPalette.neonPink,
            ),
          ],
        ),
        const Spacer(),
        Text(
          'Dernière mise à jour : ${data.lastUpdatedLabel}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}

class _StatusCounter extends StatelessWidget {
  const _StatusCounter({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              width: 6,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardData {
  const DashboardData({
    required this.temperatureReadings,
    required this.humidityReadings,
    required this.doorCycles,
    required this.doorStatus,
    required this.lastUpdated,
  });

  final List<SensorReading> temperatureReadings;
  final List<SensorReading> humidityReadings;
  final List<DoorCycleStat> doorCycles;
  final DoorStatus doorStatus;
  final DateTime lastUpdated;

  String get lastUpdatedLabel =>
      '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}';

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
        DoorCycleStat(label: 'Matin', openings: 5, closures: 5),
        DoorCycleStat(label: 'Midi', openings: 7, closures: 6),
        DoorCycleStat(label: 'Après-midi', openings: 4, closures: 5),
        DoorCycleStat(label: 'Soir', openings: 6, closures: 6),
      ],
      doorStatus: DoorStatus.open,
      lastUpdated: DateTime.now(),
    );
  }
}

class SensorReading {
  const SensorReading({required this.label, required this.value});

  final String label;
  final double value;
}

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

enum DoorStatus { open, closed }
