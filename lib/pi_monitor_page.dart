import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'core/services/config.dart';
import 'package:freego_dashboard/core/theme/app_colors.dart';

/// Internal sensor reading model for WebSocket data
class _SensorReading {
  _SensorReading({required this.timestamp, required this.temperature, required this.humidity});

  final String timestamp;
  final double temperature;
  final double humidity;
}

class PiMonitorPage extends StatefulWidget {
  final void Function(double? temperature, double? humidity)? onSensor;

  const PiMonitorPage({super.key, this.onSensor});

  @override
  State<PiMonitorPage> createState() => _PiMonitorPageState();
}

class _PiMonitorPageState extends State<PiMonitorPage> {
  // Use runtime endpoint from AppConfig so Settings can update it
  String get _wsEndpoint => AppConfig.wsEndpoint;
  final List<_SensorReading> _history = <_SensorReading>[];
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Uint8List? _latestFrame;
  bool _isConnecting = false;
  bool _streaming = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    // Auto-connect when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _connect() async {
    await _disconnect();
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting...';
    });
    try {
      final uri = Uri.parse(_wsEndpoint);
      final channel = WebSocketChannel.connect(uri);
      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: () {
          if (mounted) {
            setState(() {
              _statusMessage = 'Connection closed. Reconnecting...';
              _streaming = false;
              _channel = null;
            });
            // Auto-reconnect after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _connect();
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Connection error: $error. Reconnecting...';
              _streaming = false;
              _channel = null;
            });
            // Auto-reconnect after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _connect();
              }
            });
          }
        },
      );
      setState(() {
        _channel = channel;
        _statusMessage = null; // Hide the status message, only show Connected/Disconnected
      });
    } catch (error) {
      setState(() {
        _statusMessage = 'Failed to connect: $error. Reconnecting...';
        _streaming = false;
        _channel = null;
      });
      // Auto-reconnect after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _connect();
        }
      });
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnect() async {
    _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    setState(() {
      _channel = null;
      _streaming = false;
      _statusMessage = null; // Hide the status message
    });
  }

  void _handleMessage(dynamic data) {
    try {
      if (data is! String) {
        return;
      }
      final payload = jsonDecode(data) as Map<String, dynamic>;
      switch (payload['type']) {
        case 'sensor':
          final temperature = (payload['temperature'] as num?)?.toDouble();
          final humidity = (payload['humidity'] as num?)?.toDouble();
          final reading = _SensorReading(
            timestamp: payload['time']?.toString() ?? '--:--:--',
            temperature: temperature ?? double.nan,
            humidity: humidity ?? double.nan,
          );
          setState(() {
            _history.insert(0, reading);
            if (_history.length > 50) {
              _history.removeLast();
            }
          });
          // Call the parent callback to update the dashboard
          widget.onSensor?.call(temperature, humidity);
          break;
        case 'frame':
          final encoded = payload['data'];
          if (encoded is String) {
            setState(() => _latestFrame = base64Decode(encoded));
          }
          break;
      }
    } catch (error) {
      setState(() => _statusMessage = 'Message parsing error: $error');
    }
  }

  void _startStreaming() {
    if (_channel == null) {
      setState(() => _statusMessage = 'Connect before starting the stream.');
      return;
    }
    _channel!.sink.add('START_STREAM:15');
    setState(() {
      _streaming = true;
      _statusMessage = 'Streaming started.';
    });
  }

  void _stopStreaming() {
    if (_channel == null) {
      return;
    }
    _channel!.sink.add('STOP_STREAM');
    setState(() {
      _streaming = false;
      _statusMessage = 'Streaming stopped.';
    });
  }

  Widget _buildSensorCards() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.sensors_off_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for sensor data...',
              style: TextStyle(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    final latest = _history.first;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SensorStatCard(title: 'Temperature', value: latest.temperature, unit: '°C')),
            const SizedBox(width: 12),
            Expanded(child: _SensorStatCard(title: 'Humidity', value: latest.humidity, unit: '%')),
          ],
        ),
        if (_history.length > 1) ...[
          const SizedBox(height: 16),
          Text(
            'Recent Readings',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length > 5 ? 5 : _history.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.surface),
              itemBuilder: (context, index) {
                final reading = _history[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    '${reading.temperature.toStringAsFixed(1)}°C  •  ${reading.humidity.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    reading.timestamp,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Live Monitor',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        actions: [
          TextButton(
            onPressed: _channel == null ? (_isConnecting ? null : _connect) : _disconnect,
            style: TextButton.styleFrom(
              foregroundColor: _channel == null ? AppColors.primary : AppColors.danger,
            ),
            child: Text(_channel == null ? 'RECONNECT' : 'DISCONNECT'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (_channel != null ? AppColors.secondary : AppColors.textMuted).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.wifi_rounded,
                          color: _channel != null ? AppColors.secondary : AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      /*Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WebSocket Connection',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              _wsEndpoint,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),*/
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_channel != null ? AppColors.secondary : AppColors.textMuted).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _channel != null ? AppColors.secondary : AppColors.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _channel != null ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _channel != null ? AppColors.secondary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Camera Stream Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.videocam_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Camera Feed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      if (_streaming)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
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
                        child: ElevatedButton.icon(
                          onPressed: _streaming ? null : _startStreaming,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _streaming ? _stopStreaming : null,
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('Stop'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.textDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _latestFrame == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_off_rounded,
                                    size: 48,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No frame available',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _latestFrame!,
                                gaplessPlayback: true,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Sensor Data Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.sensors_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sensor Readings',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSensorCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorStatCard extends StatelessWidget {
  const _SensorStatCard({required this.title, required this.value, required this.unit});

  final String title;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final formatted = value.isNaN ? '--' : value.toStringAsFixed(1);
    final isTemp = unit == '°C';
    final color = isTemp ? AppColors.chartTemperature : AppColors.chartHumidity;
    final icon = isTemp ? Icons.thermostat_rounded : Icons.water_drop_rounded;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatted,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
