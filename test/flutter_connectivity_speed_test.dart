import 'package:flutter_connectivity_speed/entities/condition_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connectivity_speed/flutter_connectivity_speed.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'flutter_connectivity_speed_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;
  late ConnectivitySpeedChecker checker;

  setUp(() {
    mockClient = MockClient();
    checker = ConnectivitySpeedChecker(client: mockClient);
  });

  tearDown(() {
    checker.dispose();
  });

  group('getNetworkCondition', () {
    test('returns No Internet', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final response = http.Response('', 500); // simulate server error
      when(mockClient.get(Uri.parse(downlinkUrl)))
          .thenAnswer((_) async => response);

      final uplinkUrl = Uri.parse('https://httpbin.org/post');
      final postResponse = http.Response('', 500); // simulate server error
      when(mockClient.post(uplinkUrl, body: anyNamed('body')))
          .thenAnswer((_) async => postResponse);

      final stream = checker.onNetworkConditionChanged.take(1);
      final result = await stream.first;

      expect(result.condition, ConditionType.noInternet);
    });

    test('returns Low Bandwidth', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 10000, 200,
          headers: {'content-length': '100000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 2000)); // Simulate slow network
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '100000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 4000)); // Simulate slow network
        return uplinkResponse;
      });

      final stream = checker.onNetworkConditionChanged.take(1);
      final result = await stream.first;

      expect(result.condition, ConditionType.lowBandwidth);
    });

    test('returns High Latency', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 10000, 200,
          headers: {'content-length': '100000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 1500)); // Simulate high latency
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '100000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 1500)); // Simulate high latency
        return uplinkResponse;
      });

      final stream = checker.onNetworkConditionChanged.take(1);
      final result = await stream.first;

      expect(result.condition, ConditionType.highLatency);
    });

    test('returns Good', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 100000, 200,
          headers: {'content-length': '1000000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '1000000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return uplinkResponse;
      });

      final stream = checker.onNetworkConditionChanged.take(1);
      final result = await stream.first;

      expect(result.condition, ConditionType.good);
    });
  });
}
