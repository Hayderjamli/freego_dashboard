import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class PiViewer extends StatefulWidget {
  final void Function(double? temperature, double? humidity)? onSensor;
  final String wsUrl;

  const PiViewer({
    super.key,
    this.onSensor,
    this.wsUrl = 'ws://192.168.137.104:8000',
  });

  @override
  State<PiViewer> createState() => _PiViewerState();
}

class _PiViewerState extends State<PiViewer> {
  late WebSocketChannel channel;
  String status = 'Disconnected';
  String lastFrame = '';
  double? currentTemperature;
  double? currentHumidity;
  bool autoConnect = true;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (autoConnect) {
        _connect();
      }
    });
  }

  void _connect() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(widget.wsUrl));
      if (mounted) {
        setState(() {
          status = 'Connected';
          isConnected = true;
        });
      }

      channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'sensor') {
              double? temp = (data['temperature'] as num?)?.toDouble();
              double? humidity = (data['humidity'] as num?)?.toDouble();
              if (mounted) {
                setState(() {
                  currentTemperature = temp;
                  currentHumidity = humidity;
                });
              }
              widget.onSensor?.call(temp, humidity);
            } else if (data['type'] == 'frame') {
              if (mounted) {
                setState(() {
                  lastFrame = data['data'] ?? '';
                });
              }
            }
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              status = 'Error: $error. Reconnecting...';
              isConnected = false;
            });
            // Auto-reconnect after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                _connect();
              }
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              status = 'Disconnected. Reconnecting...';
              isConnected = false;
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
    } catch (e) {
      if (mounted) {
        setState(() {
          status = 'Connection Failed: $e. Reconnecting...';
          isConnected = false;
        });
        // Auto-reconnect after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _connect();
          }
        });
      }
    }
  }

  void _disconnect() {
    channel.sink.close();
    if (mounted) {
      setState(() {
        status = 'Disconnected';
        isConnected = false;
      });
    }
  }

  void _requestFrame() {
    if (isConnected) {
      channel.sink.add(jsonEncode({'action': 'get_frame'}));
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      channel.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pi Live Monitor',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildDataCard(),
          const SizedBox(height: 16),
          _buildControlsCard(),
          const SizedBox(height: 16),
          if (lastFrame.isNotEmpty) _buildFramePreview(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isConnected
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connection Status',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    final tempStr =
        currentTemperature != null
            ? '${currentTemperature!.toStringAsFixed(1)}°C'
            : '--';
    final humStr =
        currentHumidity != null
            ? '${currentHumidity!.toStringAsFixed(1)}%'
            : '--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sensor Data',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Temperature',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tempStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Humidity',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    humStr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        border: Border.all(color: Colors.purple, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isConnected ? null : _connect,
                icon: const Icon(Icons.connect_without_contact),
                label: const Text('Connect'),
              ),
              ElevatedButton.icon(
                onPressed: isConnected ? _disconnect : null,
                icon: const Icon(Icons.power_settings_new),
                label: const Text('Disconnect'),
              ),
              ElevatedButton.icon(
                onPressed: isConnected ? _requestFrame : null,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Get Frame'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: autoConnect,
                onChanged: (bool? value) {
                  setState(() {
                    autoConnect = value ?? false;
                  });
                },
              ),
              const Text(
                'Auto-connect on startup',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFramePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Frame',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            lastFrame.length > 100
                ? '${lastFrame.substring(0, 100)}...'
                : lastFrame,
            style: const TextStyle(fontSize: 10, fontFamily: 'Courier'),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
