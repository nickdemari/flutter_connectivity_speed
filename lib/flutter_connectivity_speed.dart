import 'dart:async';
import 'package:flutter_connectivity_speed/entities/condition_type.dart';
import 'package:flutter_connectivity_speed/entities/network_connection.dart';
import 'package:http/http.dart' as http;

class FlutterConnectivitySpeed {
  static final FlutterConnectivitySpeed _instance =
      FlutterConnectivitySpeed._internal();
  late http.Client _client;
  late StreamController<NetworkCondition> _controller;
  Timer? _timer;

  factory FlutterConnectivitySpeed() {
    return _instance;
  }

  FlutterConnectivitySpeed._internal() {
    _client = http.Client();
    _controller = StreamController<NetworkCondition>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );
  }

  set client(http.Client client) {
    _client = client;
  }

  Stream<NetworkCondition> get onNetworkConditionChanged => _controller.stream;

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
      final condition = await getNetworkCondition();
      if (!_controller.isClosed) {
        _controller.add(condition);
      }
    });
  }

  void _stopMonitoring() {
    _timer?.cancel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }

  Future<double> _measureDownlinkSpeed() async {
    const url =
        'https://www.google.com/images/phd/px.gif'; // A small file to download
    final startTime = DateTime.now();
    final response = await _client.get(Uri.parse(url));
    final endTime = DateTime.now();

    if (response.statusCode != 200) {
      return 0;
    }

    final duration = endTime.difference(startTime).inMilliseconds;
    final bytes = response.contentLength ?? 0;
    return (bytes / duration) * 1000; // bytes per second
  }

  Future<double> _measureUplinkSpeed() async {
    final url =
        Uri.parse('https://httpbin.org/post'); // An endpoint to upload to
    final fileContent =
        List<int>.generate(1024 * 16, (i) => i % 256); // 16 KB of data
    final startTime = DateTime.now();
    final response = await _client.post(url, body: fileContent);
    final endTime = DateTime.now();

    if (response.statusCode != 200) {
      return 0;
    }

    final duration = endTime.difference(startTime).inMilliseconds;
    final bytes = fileContent.length;
    return (bytes / duration) * 1000; // bytes per second
  }

  Future<NetworkCondition> getNetworkCondition() async {
    final downlinkSpeed = await _measureDownlinkSpeed();
    final uplinkSpeed = await _measureUplinkSpeed();

    ConditionType condition;

    if (downlinkSpeed == 0 || uplinkSpeed == 0) {
      condition = ConditionType.noInternet;
    } else if (downlinkSpeed < 1000 || uplinkSpeed < 500) {
      // Adjusted thresholds for Low Bandwidth
      condition = ConditionType.lowBandwidth;
    } else if (downlinkSpeed < 3000 || uplinkSpeed < 1500) {
      // Adjusted thresholds for High Latency
      condition = ConditionType.highLatency;
    } else {
      condition = ConditionType.good;
    }

    return NetworkCondition(
      downlinkSpeed: downlinkSpeed,
      uplinkSpeed: uplinkSpeed,
      condition: condition,
    );
  }

  void dispose() {
    _stopMonitoring();
  }
}
