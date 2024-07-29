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
  late FlutterConnectivitySpeed checker;

  setUp(() {
    mockClient = MockClient();
    checker = FlutterConnectivitySpeed();
    checker.client = mockClient; // Inject the mock client
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

      final result = await checker.getNetworkCondition();
      expect(result.condition, ConditionType.noInternet);
    });

    test('returns Low Bandwidth', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 1000, 200,
          headers: {'content-length': '4000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 5000)); // Simulate slow network
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '4000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 5000)); // Simulate slow network
        return uplinkResponse;
      });

      final result = await checker.getNetworkCondition();
      expect(result.condition, ConditionType.lowBandwidth);
    });

    test('returns High Latency', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 1000, 200,
          headers: {'content-length': '4000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 2000)); // Simulate high latency
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '4000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 2000)); // Simulate high latency
        return uplinkResponse;
      });

      final result = await checker.getNetworkCondition();
      expect(result.condition, ConditionType.highLatency);
    });

    test('returns Good', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 100000, 200,
          headers: {'content-length': '400000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '400000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return uplinkResponse;
      });

      final result = await checker.getNetworkCondition();
      expect(result.condition, ConditionType.good);
    });
  });

  group('onNetworkConditionChanged', () {
    test('emits the network condition', () async {
      const downlinkUrl = 'https://www.google.com/images/phd/px.gif';
      final downlinkResponse = http.Response('data' * 100000, 200,
          headers: {'content-length': '400000'});
      when(mockClient.get(Uri.parse(downlinkUrl))).thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return downlinkResponse;
      });

      const uplinkUrl = 'https://httpbin.org/post';
      final uplinkResponse =
          http.Response('', 200, headers: {'content-length': '400000'});
      when(mockClient.post(Uri.parse(uplinkUrl), body: anyNamed('body')))
          .thenAnswer((_) async {
        await Future.delayed(
            const Duration(milliseconds: 500)); // Simulate fast network
        return uplinkResponse;
      });

      final condition = await checker.onNetworkConditionChanged.first;

      expect(condition.condition, ConditionType.good);
    });
  });
}
