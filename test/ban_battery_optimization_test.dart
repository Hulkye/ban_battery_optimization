import 'package:ban_battery_optimization/ban_battery_optimization.dart';
import 'package:ban_battery_optimization/ban_battery_optimization_method_channel.dart';
import 'package:ban_battery_optimization/ban_battery_optimization_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeBanBatteryOptimizationPlatform
    with MockPlatformInterfaceMixin
    implements BanBatteryOptimizationPlatform {
  FakeBanBatteryOptimizationPlatform({
    required this.snapshot,
    this.isOptimizationEnabledValue = false,
    this.requestWithResultValue = true,
    this.throwOnRequestWithResult = false,
    this.throwOnOpenSettings = false,
  });

  final Map<String, dynamic> snapshot;
  final bool isOptimizationEnabledValue;
  final bool requestWithResultValue;
  final bool throwOnRequestWithResult;
  final bool throwOnOpenSettings;

  bool openSettingsCalled = false;

  @override
  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() async =>
      snapshot;

  @override
  Future<bool> isBatteryOptimizationEnabled() async =>
      isOptimizationEnabledValue;

  @override
  Future<void> openBatteryOptimizationSettings() async {
    openSettingsCalled = true;
    if (throwOnOpenSettings) {
      throw PlatformException(code: 'open_failed');
    }
  }

  @override
  Future<bool> openAutoStartSettings() async => true;

  @override
  Future<void> requestDisableBatteryOptimization() async {}

  @override
  Future<bool> requestDisableBatteryOptimizationWithResult() async {
    if (throwOnRequestWithResult) {
      throw PlatformException(code: 'request_failed');
    }
    return requestWithResultValue;
  }
}

void main() {
  final initialPlatform = BanBatteryOptimizationPlatform.instance;

  tearDown(() {
    BanBatteryOptimizationPlatform.instance = initialPlatform;
  });

  test('$MethodChannelBanBatteryOptimization is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelBanBatteryOptimization>(),
    );
  });

  test('getBatteryRestrictionSnapshot returns typed diagnostics', () async {
    final fake = FakeBanBatteryOptimizationPlatform(
      snapshot: <String, dynamic>{
        'isSupported': true,
        'androidSdkInt': 34,
        'manufacturer': 'samsung',
        'isBatteryOptimizationEnabled': true,
        'isPowerSaveModeOn': true,
        'canOpenAutoStartSettings': false,
      },
    );
    BanBatteryOptimizationPlatform.instance = fake;

    final snapshot =
        await BanBatteryOptimization.getBatteryRestrictionSnapshot();

    expect(snapshot.isSupported, true);
    expect(snapshot.androidSdkInt, 34);
    expect(snapshot.manufacturer, 'samsung');
    expect(snapshot.isBatteryOptimizationEnabled, true);
    expect(snapshot.isPowerSaveModeOn, true);
    expect(snapshot.canOpenAutoStartSettings, false);
  });

  test(
    'ensureOptimizationDisabledDetailed returns unsupported on non-Android',
    () async {
      final fake = FakeBanBatteryOptimizationPlatform(
        snapshot: <String, dynamic>{'isSupported': false},
      );
      BanBatteryOptimizationPlatform.instance = fake;

      final outcome =
          await BanBatteryOptimization.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.unsupported);
      expect(outcome.isOptimizationDisabled, true);
      expect(outcome.succeeded, true);
    },
  );

  test('ensureOptimizationDisabledDetailed returns alreadyDisabled', () async {
    final fake = FakeBanBatteryOptimizationPlatform(
      snapshot: <String, dynamic>{
        'isSupported': true,
        'isBatteryOptimizationEnabled': false,
      },
    );
    BanBatteryOptimizationPlatform.instance = fake;

    final outcome =
        await BanBatteryOptimization.ensureOptimizationDisabledDetailed();

    expect(outcome.status, OptimizationOutcomeStatus.alreadyDisabled);
    expect(outcome.isOptimizationDisabled, true);
  });

  test(
    'ensureOptimizationDisabledDetailed returns disabledAfterPrompt',
    () async {
      final fake = FakeBanBatteryOptimizationPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        requestWithResultValue: true,
      );
      BanBatteryOptimizationPlatform.instance = fake;

      final outcome =
          await BanBatteryOptimization.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.disabledAfterPrompt);
      expect(outcome.isOptimizationDisabled, true);
    },
  );

  test(
    'ensureOptimizationDisabledDetailed opens settings on request failure',
    () async {
      final fake = FakeBanBatteryOptimizationPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        throwOnRequestWithResult: true,
      );
      BanBatteryOptimizationPlatform.instance = fake;

      final outcome =
          await BanBatteryOptimization.ensureOptimizationDisabledDetailed();

      expect(outcome.status, OptimizationOutcomeStatus.settingsOpened);
      expect(outcome.isOptimizationDisabled, false);
      expect(fake.openSettingsCalled, true);
    },
  );

  test(
    'legacy ensureOptimizationDisabled returns false when still enabled',
    () async {
      final fake = FakeBanBatteryOptimizationPlatform(
        snapshot: <String, dynamic>{
          'isSupported': true,
          'isBatteryOptimizationEnabled': true,
        },
        isOptimizationEnabledValue: true,
        requestWithResultValue: false,
      );
      BanBatteryOptimizationPlatform.instance = fake;

      final ok = await BanBatteryOptimization.ensureOptimizationDisabled(
        openSettingsIfDirectRequestNotPossible: false,
      );

      expect(ok, false);
    },
  );
}
