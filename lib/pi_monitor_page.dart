import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SensorReading {
  SensorReading({required this.timestamp, required this.temperature, required this.humidity});

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
  // Hardcoded WebSocket endpoint (per project requirement)
  static const String _wsEndpoint = 'ws://192.168.137.104:8000';
  final List<SensorReading> _history = <SensorReading>[];
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
        _statusMessage = 'Connected to ${uri.host}:${uri.port}';
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
      _statusMessage = 'Disconnected.';
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
          final reading = SensorReading(
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
      return const Center(child: Text('Waiting for sensor data...'));
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
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final reading = _history[index];
              return ListTile(
                title: Text('${reading.temperature.toStringAsFixed(1)} °C'),
                subtitle: Text('${reading.humidity.toStringAsFixed(1)} %'),
                trailing: Text(reading.timestamp),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Pi Monitor'),
        actions: [
          TextButton(
            onPressed: _channel == null ? (_isConnecting ? null : _connect) : _disconnect,
            child: Text(_channel == null ? 'RECONNECT' : 'DISCONNECT'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('WebSocket Endpoint', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    // Endpoint is hardcoded to ensure the app always connects
                    // to the Raspberry Pi at 192.168.137.104:8000
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        _wsEndpoint,
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_statusMessage != null)
                      Text(
                        _statusMessage!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _streaming ? null : _startStreaming,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Stream'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _streaming ? _stopStreaming : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop Stream'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _latestFrame == null
                            ? const Center(child: Text('No frame yet', style: TextStyle(color: Colors.white54)))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildSensorCards(),
              ),
            ],
          ),
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
    final textTheme = Theme.of(context).textTheme;
    final surface = Theme.of(context).colorScheme.surface;
    final secondary = Theme.of(context).colorScheme.secondary;
    final formatted = value.isNaN ? '--' : value.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [surface.withOpacity(0.9), surface.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium?.copyWith(color: secondary.withOpacity(0.8))),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatted,
                style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(unit, style: textTheme.titleMedium),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
