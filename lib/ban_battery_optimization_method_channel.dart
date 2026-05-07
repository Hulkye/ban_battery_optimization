import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ban_battery_optimization_platform_interface.dart';

/// [BanBatteryOptimizationPlatform] 的 MethodChannel 实现。
class MethodChannelBanBatteryOptimization extends BanBatteryOptimizationPlatform {
  /// 用于与原生平台通信的方法通道。
  @visibleForTesting
  final methodChannel = const MethodChannel('ban_battery_optimization');

  @override
  Future<bool> isBatteryOptimizationEnabled() async {
    final isEnabled = await methodChannel.invokeMethod<bool>(
      'isBatteryOptimizationEnabled',
    );
    return isEnabled ?? false;
  }

  @override
  Future<void> requestDisableBatteryOptimization() async {
    await methodChannel.invokeMethod<void>('requestDisableBatteryOptimization');
  }

  @override
  Future<bool> requestDisableBatteryOptimizationWithResult() async {
    final disabled = await methodChannel.invokeMethod<bool>(
      'requestDisableBatteryOptimizationWithResult',
    );
    return disabled ?? false;
  }

  @override
  Future<void> openBatteryOptimizationSettings() async {
    await methodChannel.invokeMethod<void>('openBatteryOptimizationSettings');
  }

  @override
  Future<bool> openAutoStartSettings() async {
    final opened = await methodChannel.invokeMethod<bool>(
      'openAutoStartSettings',
    );
    return opened ?? false;
  }

  @override
  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() async {
    final snapshot = await methodChannel.invokeMapMethod<String, dynamic>(
      'getBatteryRestrictionSnapshot',
    );
    return snapshot ?? <String, dynamic>{};
  }
}
