import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau de bord',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const OverviewPage(),
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

    final totalOpenings = data.doorCycles.fold<int>(
      0,
      (sum, stat) => sum + stat.openings,
    );
    final totalClosures = data.doorCycles.fold<int>(
      0,
      (sum, stat) => sum + stat.closures,
    );
    final statusText =
        data.doorStatus == DoorStatus.open ? 'Ouverte' : 'Fermée';
    final statusColor =
        data.doorStatus == DoorStatus.open ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text("Vue d'ensemble")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 680
                  ? 2
                  : 1;
          final itemWidth =
              columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - (columns - 1) * 16) / columns;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
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
                            (minTemperature != null && maxTemperature != null)
                                ? 'Min ${minTemperature.toStringAsFixed(1)}°C · Max ${maxTemperature.toStringAsFixed(1)}°C'
                                : null,
                        icon: Icons.thermostat,
                        color: Colors.deepOrange,
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
                        color: Colors.blue,
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
                        color: statusColor,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _OverviewTile(
                        title: 'Cycles de la porte',
                        value:
                            '$totalOpenings ouvertures / $totalClosures fermetures',
                        subtitle: 'Aujourd\'hui',
                        icon: Icons.autorenew,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DashboardPage(data: data),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  label: const Text('Voir le tableau de bord détaillé'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth > 1100
                    ? 3
                    : constraints.maxWidth > 760
                    ? 2
                    : 1;
            final itemWidth =
                (constraints.maxWidth - (columns - 1) * 16) / columns;

            return SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: DashboardCard(
                      title: 'Température',
                      subtitle: 'Évolution sur 24h',
                      contentHeight: 220,
                      child: TemperatureChart(
                        readings: data.temperatureReadings,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DashboardCard(
                      title: 'Humidité',
                      subtitle: 'Évolution sur 24h',
                      contentHeight: 220,
                      child: HumidityChart(readings: data.humidityReadings),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DashboardCard(
                      title: 'Porte',
                      subtitle: 'Ouvertures & fermetures',
                      contentHeight: 220,
                      child: DoorUsageChart(stats: data.doorCycles),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DashboardCard(
                      title: 'Statut de la porte',
                      contentHeight: 160,
                      child: DoorStatusPanel(data: data),
                    ),
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

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
            if (icon != null) const SizedBox(height: 16),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ],
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
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double? contentHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final content =
        contentHeight != null
            ? SizedBox(height: contentHeight!, child: child)
            : child;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
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

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          drawVerticalLine: false,
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
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.withOpacity(0.25),
                  Colors.orange.withOpacity(0.05),
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

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
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
            gradient: const LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blue],
            ),
            barWidth: 4,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent.withOpacity(0.25),
                  Colors.blue.withOpacity(0.05),
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
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: entry.value.closures.toDouble(),
                    width: 14,
                    color: Colors.red[400],
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
        _LegendEntry(label: 'Ouvertures', color: Colors.green),
        SizedBox(width: 20),
        _LegendEntry(label: 'Fermetures', color: Colors.red),
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
    final statusColor = isOpen ? Colors.green : Colors.red;
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
              color: Colors.green[400]!,
            ),
            _StatusCounter(
              label: 'Fermetures',
              value: totalClosures,
              color: Colors.red[400]!,
            ),
          ],
        ),
        const Spacer(),
        Text(
          'Dernière mise à jour : ${data.lastUpdatedLabel}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
            Container(
              width: 6,
              height: 28,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
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
