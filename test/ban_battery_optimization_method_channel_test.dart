import 'package:ban_battery_optimization/ban_battery_optimization_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelBanBatteryOptimization();
  const channel = MethodChannel('ban_battery_optimization');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          switch (call.method) {
            case 'isBatteryOptimizationEnabled':
              return false;
            case 'requestDisableBatteryOptimizationWithResult':
              return true;
            case 'openAutoStartSettings':
              return true;
            case 'getBatteryRestrictionSnapshot':
              return <String, dynamic>{
                'isSupported': true,
                'androidSdkInt': 34,
                'manufacturer': 'google',
                'isBatteryOptimizationEnabled': false,
                'isPowerSaveModeOn': false,
                'canOpenAutoStartSettings': true,
              };
            case 'requestDisableBatteryOptimization':
            case 'openBatteryOptimizationSettings':
              return null;
            default:
              throw PlatformException(code: 'not_implemented');
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isBatteryOptimizationEnabled returns false', () async {
    expect(await platform.isBatteryOptimizationEnabled(), false);
  });

  test('openAutoStartSettings returns true', () async {
    expect(await platform.openAutoStartSettings(), true);
  });

  test('requestDisableBatteryOptimizationWithResult returns true', () async {
    expect(await platform.requestDisableBatteryOptimizationWithResult(), true);
  });

  test('getBatteryRestrictionSnapshot returns map', () async {
    final snapshot = await platform.getBatteryRestrictionSnapshot();
    expect(snapshot['isSupported'], true);
    expect(snapshot['androidSdkInt'], 34);
    expect(snapshot['manufacturer'], 'google');
  });
}
