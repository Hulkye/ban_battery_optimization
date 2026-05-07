import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ban_battery_optimization_method_channel.dart';

/// `ban_battery_optimization` 的平台接口定义。
abstract class BanBatteryOptimizationPlatform extends PlatformInterface {
  BanBatteryOptimizationPlatform() : super(token: _token);

  static final Object _token = Object();

  /// 默认的平台实现，基于 MethodChannel。
  static BanBatteryOptimizationPlatform _instance =
      MethodChannelBanBatteryOptimization();

  /// 当前生效的平台实现实例。
  static BanBatteryOptimizationPlatform get instance => _instance;

  /// 替换平台实现，通常用于测试或自定义平台接入。
  static set instance(BanBatteryOptimizationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 返回当前应用是否仍启用了系统电池优化。
  Future<bool> isBatteryOptimizationEnabled() {
    throw UnimplementedError(
      'isBatteryOptimizationEnabled() has not been implemented.',
    );
  }

  /// 请求系统将当前应用加入电池优化白名单。
  Future<void> requestDisableBatteryOptimization() {
    throw UnimplementedError(
      'requestDisableBatteryOptimization() has not been implemented.',
    );
  }

  /// 请求系统授权，并在流程结束后返回是否已成功关闭限制。
  Future<bool> requestDisableBatteryOptimizationWithResult() {
    throw UnimplementedError(
      'requestDisableBatteryOptimizationWithResult() has not been implemented.',
    );
  }

  /// 打开系统电池优化设置页。
  Future<void> openBatteryOptimizationSettings() {
    throw UnimplementedError(
      'openBatteryOptimizationSettings() has not been implemented.',
    );
  }

  /// 尝试打开厂商自启动或后台管理设置页。
  Future<bool> openAutoStartSettings() {
    throw UnimplementedError(
      'openAutoStartSettings() has not been implemented.',
    );
  }

  /// 获取当前设备的电池限制诊断信息。
  Future<Map<String, dynamic>> getBatteryRestrictionSnapshot() {
    throw UnimplementedError(
      'getBatteryRestrictionSnapshot() has not been implemented.',
    );
  }
}
