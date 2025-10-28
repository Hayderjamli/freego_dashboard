import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_dashboard/login_page.dart';

class AppPalette {
  const AppPalette._();

  static const Color midnight = Color(0xFF050A18);
  static const Color deepNavy = Color(0xFF0F1728);
  static const Color slate = Color(0xFF182338);
  static const Color steel = Color(0xFF1F2D43);
  static const Color storm = Color(0xFF27344B);
  static const Color mist = Color(0xFF9EB1CC);
  static const Color sky = Color(0xFF4FA8FF);
  static const Color ice = Color(0xFF7FC7FF);
  static const Color lavender = Color(0xFFC3CEED);
  static const Color highlight = Color(0xFF66E0FF);
  static const Color openAccent = Color(0xFF56F4D2);
  static const Color closedAccent = Color(0xFFADB8C7);
  static const Color cardBorder = Color(0x33FFFFFF);

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [deepNavy, midnight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get panelGradient => const LinearGradient(
    colors: [slate, steel],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [sky, ice],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau de bord',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.sky,
          brightness: Brightness.dark,
        ).copyWith(
          background: AppPalette.deepNavy,
          surface: AppPalette.slate,
          primary: AppPalette.sky,
          secondary: AppPalette.ice,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: AppPalette.deepNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            backgroundColor: AppPalette.highlight,
            foregroundColor: AppPalette.deepNavy,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
        textTheme: ThemeData(
          brightness: Brightness.dark,
        ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

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
    final data = DashboardData.sample();

    return Container(
      decoration: BoxDecoration(gradient: AppPalette.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            const OverviewPage(),
            DashboardPage(data: data),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Vue d\'ensemble',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Graphiques',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: AppPalette.slate.withOpacity(0.8),
          selectedItemColor: AppPalette.highlight,
          unselectedItemColor: AppPalette.mist,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          elevation: 0,
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DashboardData.sample();
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
        title: const Text("Vue d'ensemble"),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
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
                    title: 'Points clés',
                    subtitle:
                        'Synthèse des indicateurs environnementaux et du statut de la porte',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Température actuelle',
                          value:
                              latestTemperature != null
                                  ? '${latestTemperature.toStringAsFixed(1)}°C'
                                  : '--',
                          subtitle:
                              (minTemperature != null &&
                                      maxTemperature != null)
                                  ? 'Min ${minTemperature.toStringAsFixed(1)}°C · Max ${maxTemperature.toStringAsFixed(1)}°C'
                                  : null,
                          icon: Icons.thermostat,
                          accent: AppPalette.accentGradient,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Humidité actuelle',
                          value:
                              latestHumidity != null
                                  ? '${latestHumidity.toStringAsFixed(0)}%'
                                  : '--',
                          subtitle:
                              (minHumidity != null && maxHumidity != null)
                                  ? 'Min ${minHumidity.toStringAsFixed(0)}% · Max ${maxHumidity.toStringAsFixed(0)}%'
                                  : null,
                          icon: Icons.water_drop,
                          accent: const LinearGradient(
                            colors: [AppPalette.lavender, AppPalette.ice],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Statut de la porte',
                          value: statusText,
                          subtitle:
                              'Dernière mise à jour : ${data.lastUpdatedLabel}',
                          icon: Icons.meeting_room,
                          badgeColor:
                              data.doorStatus == DoorStatus.open
                                  ? AppPalette.openAccent
                                  : AppPalette.closedAccent,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _OverviewTile(
                          title: 'Nbre de fermeture et ouverture',
                          value: '$totalDoorCycles',
                          subtitle: 'Aujourd\'hui',
                          icon: Icons.autorenew,
                          accent: const LinearGradient(
                            colors: [AppPalette.sky, AppPalette.mist],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
    final ranges = ['1h', '24h', '7j'];
    return SegmentedButton<String>(
      segments: ranges.map((range) {
        return ButtonSegment<String>(
          value: range,
          label: Text(range),
        );
      }).toList(),
      selected: {selectedRange},
      onSelectionChanged: (newSelection) {
        onChanged(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: AppPalette.steel,
        foregroundColor: AppPalette.mist,
        selectedForegroundColor: AppPalette.deepNavy,
        selectedBackgroundColor: AppPalette.highlight,
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

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppPalette.panelGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FreeGoLogo(size: 38),
          const SizedBox(height: 18),
          Text(
            'Bienvenue',
            style: textTheme.labelLarge?.copyWith(
              color: AppPalette.mist,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Surveillance du domicile',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0x3354B5FF),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: AppPalette.ice,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Synchronisé à $lastUpdated',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPalette.lavender,
                ),
              ),
            ],
          ),
        ],
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
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppPalette.mist,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class FreeGoLogo extends StatelessWidget {
  const FreeGoLogo({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [AppPalette.sky, AppPalette.highlight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final textStyle = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
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
              right: -size * 0.18,
              top: -size * 0.55,
              child: Transform.rotate(
                angle: -0.1,
                child: Icon(
                  Icons.spa,
                  size: size * 0.7,
                  color: AppPalette.highlight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final valueStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Colors.white,
    );

    final gradient = accent ?? AppPalette.panelGradient;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2F000000),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: AppPalette.lavender, size: 24),
                ),
              if (icon != null) const SizedBox(height: 18),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              badgeColor != null
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: badgeColor!.withOpacity(0.45)),
                    ),
                    child: Text(value, style: valueStyle),
                  )
                  : Text(value, style: valueStyle),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.72),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content =
        contentHeight != null
            ? SizedBox(height: contentHeight!, child: child)
            : child;

    return Container(
      decoration: BoxDecoration(
        gradient: AppPalette.panelGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppPalette.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 26,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: AppPalette.ice, size: 26),
              ),
            if (icon != null) const SizedBox(height: 18),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
                color: Colors.white,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 20),
            content,
          ],
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
      colors: [AppPalette.sky, AppPalette.ice],
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
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppPalette.sky.withOpacity(0.25),
                  AppPalette.sky.withOpacity(0.04),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
      colors: [AppPalette.lavender, AppPalette.sky],
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
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppPalette.lavender.withOpacity(0.25),
                  AppPalette.sky.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
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
                    width: 14,
                    color: AppPalette.openAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: entry.value.closures.toDouble(),
                    width: 14,
                    color: AppPalette.closedAccent,
                    borderRadius: BorderRadius.circular(6),
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
        _LegendEntry(label: 'Ouvertures', color: AppPalette.openAccent),
        SizedBox(width: 20),
        _LegendEntry(label: 'Fermetures', color: AppPalette.closedAccent),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
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
        isOpen ? AppPalette.openAccent : AppPalette.closedAccent;
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
              color: AppPalette.openAccent,
            ),
            _StatusCounter(
              label: 'Fermetures',
              value: totalClosures,
              color: AppPalette.closedAccent,
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
