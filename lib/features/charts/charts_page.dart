import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:freego_dashboard/core/theme/app_colors.dart';
import 'package:freego_dashboard/core/constants/models.dart';
import 'package:freego_dashboard/shared/widgets/dashboard_widgets.dart';

/// Charts Page - Line charts for temperature and humidity
/// 
/// Shows real-time and historical data visualization.
class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key, required this.data});

  final DashboardData data;

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  String _selectedRange = '24h';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Content
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverToBoxAdapter(
                child: _buildContent(context, isTablet),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track sensor data over time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeRangeSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final ranges = ['1h', '24h', '7d', '30d'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ranges.map((range) {
          final isSelected = _selectedRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRange = range;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                range,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isTablet) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTemperatureChart(context)),
          const SizedBox(width: 16),
          Expanded(child: _buildHumidityChart(context)),
        ],
      );
    }

    return Column(
      children: [
        _buildTemperatureChart(context),
        const SizedBox(height: 16),
        _buildHumidityChart(context),
      ],
    );
  }

  Widget _buildTemperatureChart(BuildContext context) {
    final readings = widget.data.temperatureReadings;
    
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.chartTemperature.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.thermostat_rounded,
                  color: AppColors.chartTemperature,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last $_selectedRange',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (readings.isNotEmpty)
                Text(
                  '${readings.last.value.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.chartTemperature,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: readings.isEmpty
                ? _buildEmptyChart('No temperature data')
                : _buildLineChart(
                    readings,
                    AppColors.chartTemperature,
                    '°C',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityChart(BuildContext context) {
    final readings = widget.data.humidityReadings;
    
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.chartHumidity.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.chartHumidity,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Humidity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last $_selectedRange',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (readings.isNotEmpty)
                Text(
                  '${readings.last.value.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.chartHumidity,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: readings.isEmpty
                ? _buildEmptyChart('No humidity data')
                : _buildLineChart(
                    readings,
                    AppColors.chartHumidity,
                    '%',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<SensorReading> readings, Color color, String unit) {
    if (readings.isEmpty) return _buildEmptyChart('No data available');

    final spots = readings
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    final minY = readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    final maxY = readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceVariant,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
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
                if (readings.length > 5 && index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    readings[index].label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.textDark,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toStringAsFixed(1)}$unit',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
