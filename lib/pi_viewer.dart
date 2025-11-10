import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Default websocket URL - edit if needed.
const String defaultPiWebSocketUrl = 'ws://192.168.137.104:8000';

class PiViewer extends StatefulWidget {
  final String wsUrl;

  /// Optional callback invoked when a sensor message is received.
  final void Function(double? temperature, double? humidity)? onSensor;
  const PiViewer({
    super.key,
    this.wsUrl = defaultPiWebSocketUrl,
    this.onSensor,
  });

  @override
  State<PiViewer> createState() => _PiViewerState();
}

class _PiViewerState extends State<PiViewer> {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  String _status = 'disconnected';

  Uint8List? _lastFrame;
  double? _temperature;
  double? _humidity;

  Timer? _autoTimer;
  bool _autoPull = false;

  @override
  void initState() {
    super.initState();
    // Auto-connect on widget creation to the configured/default WebSocket URL.
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  Future<void> _connect() async {
    final url = widget.wsUrl.trim();
    if (url.isEmpty) {
      setState(() => _status = 'invalid url');
      return;
    }

    setState(() {
      _status = 'connecting';
    });

    try {
      // Attempt to connect and listen for messages. Wrap in try/catch to avoid uncaught
      // exceptions that crash the app when the network is unreachable.
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _onDone,
        onError: (err) {
          _onError(err);
        },
        cancelOnError: true,
      );
      setState(() {
        _status = 'connected';
      });
    } catch (e) {
      setState(() {
        _status = 'error: $e';
      });
      try {
        await _sub?.cancel();
      } catch (_) {}
      try {
        await _channel?.sink.close();
      } catch (_) {}
      _channel = null;
      _sub = null;
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final msg = json.decode(raw as String);
      if (msg is Map<String, dynamic>) {
        if (msg['type'] == 'sensor') {
          final t = (msg['temperature'] is num)
              ? (msg['temperature'] as num).toDouble()
              : null;
          final h = (msg['humidity'] is num)
              ? (msg['humidity'] as num).toDouble()
              : null;
          setState(() {
            _temperature = t;
            _humidity = h;
          });
          // notify parent widget if it wants updates
          try {
            widget.onSensor?.call(t, h);
          } catch (_) {}
        } else if (msg['type'] == 'frame' && msg['data'] is String) {
          final b = base64Decode(msg['data'] as String);
          setState(() => _lastFrame = Uint8List.fromList(b));
        }
      }
    } catch (_) {
      // Not JSON - try decode as base64 image
      try {
        final b = base64Decode(raw as String);
        setState(() => _lastFrame = Uint8List.fromList(b));
      } catch (e) {
        // ignore
      }
    }
  }

  void _onError(Object error) {
    _status = 'error';
    setState(() {});
  }

  void _onDone() {
    _status = 'closed';
    setState(() {});
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _connect();
    });
  }

  void _send(String msg) {
    if (_channel != null) {
      try {
        _channel!.sink.add(msg);
      } catch (_) {}
    }
  }

  void _requestFrame() => _send('GET_FRAME');
  void _startCamera() => _send('START_CAMERA');
  void _stopCamera() => _send('STOP_CAMERA');

  void _toggleAutoPull(bool value) {
    setState(() => _autoPull = value);
    _autoTimer?.cancel();
    if (value) {
      _autoTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _requestFrame(),
      );
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pi Camera',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Auto-connects to the default Pi WebSocket on mount.
            Text('Connecting to ${widget.wsUrl}'),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: Center(
                child: _lastFrame != null
                    ? Image.memory(_lastFrame!, gaplessPlayback: true)
                    : const Text('No frame yet'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temperature',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _temperature != null
                          ? '${_temperature!.toStringAsFixed(1)} °C'
                          : '--',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Humidity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _humidity != null
                          ? '${_humidity!.toStringAsFixed(1)} %'
                          : '--',
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _startCamera,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _stopCamera,
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: _requestFrame,
                  child: const Text('Get frame'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Auto'),
                    Switch(value: _autoPull, onChanged: _toggleAutoPull),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
