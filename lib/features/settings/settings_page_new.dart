import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_dashboard/core/theme/app_colors.dart';
import 'package:mobile_app_dashboard/core/constants/models.dart';
import 'package:mobile_app_dashboard/core/services/config.dart';
import 'package:mobile_app_dashboard/shared/widgets/dashboard_widgets.dart';
import 'package:mobile_app_dashboard/auth_service.dart';

/// Settings Page - Device info, WebSocket config, theme toggle
/// 
/// Comprehensive settings for the FreeGo dashboard.
class SettingsPageNew extends StatefulWidget {
  const SettingsPageNew({super.key, required this.settings});

  final ThresholdSettings settings;

  @override
  State<SettingsPageNew> createState() => _SettingsPageNewState();
}

class _SettingsPageNewState extends State<SettingsPageNew> {
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHumidityController;
  late TextEditingController _maxHumidityController;
  late TextEditingController _doorTimeController;
  late TextEditingController _wsEndpointController;
  
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  
  final DeviceInfo _deviceInfo = DeviceInfo.defaultDevice();

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
    _wsEndpointController = TextEditingController(
      // Default comes from AppConfig so it's shared app-wide
      text: AppConfig.wsEndpoint,
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
    _wsEndpointController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    widget.settings.minTemperature = double.tryParse(_minTempController.text) ?? -18.0;
    widget.settings.maxTemperature = double.tryParse(_maxTempController.text) ?? -8.0;
    widget.settings.minHumidity = double.tryParse(_minHumidityController.text) ?? 30.0;
    widget.settings.maxHumidity = double.tryParse(_maxHumidityController.text) ?? 70.0;
    widget.settings.maxDoorOpenMinutes = int.tryParse(_doorTimeController.text) ?? 5;
    widget.settings.notificationsEnabled = _notificationsEnabled;

    // Update runtime WebSocket endpoint used by the monitor page
    AppConfig.wsEndpoint = _wsEndpointController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Settings saved successfully'),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Device Info Section
                  _buildSectionTitle('Device Information'),
                  const SizedBox(height: 12),
                  _buildDeviceInfoCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Connection Section
                  _buildSectionTitle('Connection'),
                  const SizedBox(height: 12),
                  _buildConnectionCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Threshold Settings Section
                  _buildSectionTitle('Alert Thresholds'),
                  const SizedBox(height: 12),
                  _buildThresholdCard(),
                  
                  const SizedBox(height: 24),
                  
                  // App Settings Section
                  _buildSectionTitle('App Settings'),
                  const SizedBox(height: 12),
                  _buildAppSettingsCard(),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  _buildSaveButton(),
                  
                  const SizedBox(height: 16),
                  
                  // Sign Out Button
                  _buildSignOutButton(),
                  
                  const SizedBox(height: 32),
                ]),
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
          Expanded(
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return DashboardCard(
      child: Column(
        children: [
          _buildInfoRow('Device Name', _deviceInfo.name, Icons.devices_rounded),
          _buildDivider(),
          _buildInfoRow('Model', _deviceInfo.model, Icons.info_outline_rounded),
          _buildDivider(),
          _buildInfoRow('Firmware', _deviceInfo.firmwareVersion, Icons.system_update_rounded),
          _buildDivider(),
          _buildInfoRow('Serial Number', _deviceInfo.serialNumber, Icons.qr_code_rounded),
        ],
      ),
    );
  }

  Widget _buildConnectionCard() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.wifi_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WebSocket Endpoint',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Raspberry Pi connection URL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _wsEndpointController,
            decoration: InputDecoration(
              hintText: 'ws://192.168.x.x:8000',
              prefixIcon: const Icon(Icons.link_rounded),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Connected',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Test connection
                },
                child: const Text('Test Connection'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdCard() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notifications Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : AppColors.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: _notificationsEnabled
                      ? AppColors.secondary
                      : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Notifications',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _notificationsEnabled ? 'Enabled' : 'Disabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
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
                activeColor: AppColors.secondary,
              ),
            ],
          ),
          
          _buildDivider(),
          
          // Temperature Thresholds
          _buildThresholdRow(
            'Temperature Range',
            Icons.thermostat_rounded,
            AppColors.chartTemperature,
            _minTempController,
            _maxTempController,
            '°C',
          ),
          
          _buildDivider(),
          
          // Humidity Thresholds
          _buildThresholdRow(
            'Humidity Range',
            Icons.water_drop_rounded,
            AppColors.chartHumidity,
            _minHumidityController,
            _maxHumidityController,
            '%',
          ),
          
          _buildDivider(),
          
          // Door Open Duration
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.door_front_door_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Max Door Open',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _doorTimeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    suffixText: 'min',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          int current = int.tryParse(_doorTimeController.text) ?? 0;
                          if (current > 1) {
                            _doorTimeController.text = (current - 1).toString();
                          }
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      color: AppColors.danger,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          int current = int.tryParse(_doorTimeController.text) ?? 0;
                          _doorTimeController.text = (current + 1).toString();
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      color: AppColors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(
    String title,
    IconData icon,
    Color color,
    TextEditingController minController,
    TextEditingController maxController,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Min',
                  suffixText: unit,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        double current = double.tryParse(minController.text) ?? 0;
                        minController.text = (current - 1).toStringAsFixed(unit == '°C' ? 1 : 0);
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    color: AppColors.danger,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        double current = double.tryParse(minController.text) ?? 0;
                        minController.text = (current + 1).toStringAsFixed(unit == '°C' ? 1 : 0);
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    color: AppColors.secondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'to',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Max',
                  suffixText: unit,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        double current = double.tryParse(maxController.text) ?? 0;
                        maxController.text = (current - 1).toStringAsFixed(unit == '°C' ? 1 : 0);
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    color: AppColors.danger,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        double current = double.tryParse(maxController.text) ?? 0;
                        maxController.text = (current + 1).toStringAsFixed(unit == '°C' ? 1 : 0);
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    color: AppColors.secondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppSettingsCard() {
    return DashboardCard(
      child: Column(
        children: [
          // Theme Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _isDarkMode ? 'Enabled' : 'Disabled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // TODO: Implement theme switching
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          
          _buildDivider(),
          
          // App Version
          _buildInfoRow('App Version', '1.0.0', Icons.info_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppColors.surfaceVariant, height: 1),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await AuthService().signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
