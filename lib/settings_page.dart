import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class ThresholdSettings {
  double minTemperature;
  double maxTemperature;
  double minHumidity;
  double maxHumidity;
  int maxDoorOpenMinutes;
  bool notificationsEnabled;

  ThresholdSettings({
    this.minTemperature = 18.0,
    this.maxTemperature = 26.0,
    this.minHumidity = 40.0,
    this.maxHumidity = 70.0,
    this.maxDoorOpenMinutes = 5,
    this.notificationsEnabled = true,
  });
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settings});

  final ThresholdSettings settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumidityController;
  late TextEditingController _maxHumidityController;
  late TextEditingController _doorTimeController;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _minTempController = TextEditingController(
      text: widget.settings.minTemperature.toStringAsFixed(1),
    );
    _maxTempController = TextEditingController(
      text: widget.settings.maxTemperature.toStringAsFixed(1),
    );
    _minHumidityController = TextEditingController(
      text: widget.settings.minHumidity.toStringAsFixed(0),
    );
    _maxHumidityController = TextEditingController(
      text: widget.settings.maxHumidity.toStringAsFixed(0),
    );
    _doorTimeController = TextEditingController(
      text: widget.settings.maxDoorOpenMinutes.toString(),
    );
    _notificationsEnabled = widget.settings.notificationsEnabled;
  }

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _doorTimeController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    widget.settings.minTemperature = double.tryParse(_minTempController.text) ?? 18.0;
    widget.settings.maxTemperature = double.tryParse(_maxTempController.text) ?? 26.0;
    widget.settings.minHumidity = double.tryParse(_minHumidityController.text) ?? 40.0;
    widget.settings.maxHumidity = double.tryParse(_maxHumidityController.text) ?? 70.0;
    widget.settings.maxDoorOpenMinutes = int.tryParse(_doorTimeController.text) ?? 5;
    widget.settings.notificationsEnabled = _notificationsEnabled;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'SETTINGS SAVED!',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        backgroundColor: AppPalette.sportGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppPalette.sportGradient.createShader(bounds),
          child: const Text(
            'THRESHOLD SETTINGS',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
            style: IconButton.styleFrom(
              backgroundColor: AppPalette.sportGreen.withOpacity(0.2),
              foregroundColor: AppPalette.sportGreen,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppPalette.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationToggle(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'TEMPERATURE ALERTS',
                  Icons.thermostat_rounded,
                  AppPalette.vibrantOrange,
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  title: 'Minimum Temperature',
                  controller: _minTempController,
                  unit: '°C',
                  icon: Icons.ac_unit_rounded,
                  gradient: const LinearGradient(
                    colors: [AppPalette.electricBlue, Color(0xFF4FC3F7)],
                  ),
                  hint: 'Alert if below this value',
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  title: 'Maximum Temperature',
                  controller: _maxTempController,
                  unit: '°C',
                  icon: Icons.local_fire_department_rounded,
                  gradient: AppPalette.energyGradient,
                  hint: 'Alert if above this value',
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  'HUMIDITY ALERTS',
                  Icons.water_drop_rounded,
                  AppPalette.electricBlue,
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  title: 'Minimum Humidity',
                  controller: _minHumidityController,
                  unit: '%',
                  icon: Icons.dry_rounded,
                  gradient: const LinearGradient(
                    colors: [AppPalette.energyYellow, AppPalette.vibrantOrange],
                  ),
                  hint: 'Alert if below this value',
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  title: 'Maximum Humidity',
                  controller: _maxHumidityController,
                  unit: '%',
                  icon: Icons.water_rounded,
                  gradient: AppPalette.sportGradient,
                  hint: 'Alert if above this value',
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  'DOOR ALERTS',
                  Icons.sensor_door_rounded,
                  AppPalette.sportGreen,
                ),
                const SizedBox(height: 16),
                _buildThresholdCard(
                  title: 'Door Open Duration',
                  controller: _doorTimeController,
                  unit: 'min',
                  icon: Icons.timer_outlined,
                  gradient: const LinearGradient(
                    colors: [AppPalette.neonPink, AppPalette.vibrantOrange],
                  ),
                  hint: 'Alert if door stays open longer',
                ),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppPalette.purpleGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _notificationsEnabled
                ? AppPalette.sportGreen
                : AppPalette.textMuted.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _notificationsEnabled
                  ? AppPalette.sportGreen.withOpacity(0.3)
                  : AppPalette.richPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _notificationsEnabled
                      ? [AppPalette.sportGreen.withOpacity(0.3), AppPalette.sportGreen.withOpacity(0.1)]
                      : [AppPalette.textMuted.withOpacity(0.2), AppPalette.textMuted.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                color: _notificationsEnabled ? AppPalette.sportGreen : AppPalette.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTIFICATIONS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _notificationsEnabled ? 'Alerts enabled' : 'Alerts disabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: AppPalette.sportGreen,
              activeTrackColor: AppPalette.sportGreen.withOpacity(0.5),
              inactiveThumbColor: AppPalette.textMuted,
              inactiveTrackColor: AppPalette.textMuted.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildThresholdCard({
    required String title,
    required TextEditingController controller,
    required String unit,
    required IconData icon,
    required LinearGradient gradient,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient.colors.length > 1
            ? LinearGradient(
                colors: gradient.colors.map((c) => c.withOpacity(0.15)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient.colors.length == 1 ? gradient.colors[0].withOpacity(0.15) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors[0].withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors[0].withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.cardDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: gradient.colors[0].withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      hintText: '0.0',
                      hintStyle: TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors[0].withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveSettings,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: AppPalette.sportGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppPalette.electricBlue.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.black,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'SAVE SETTINGS',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
