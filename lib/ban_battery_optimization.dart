import 'dart:async';

import 'package:flutter/services.dart';

import 'ban_battery_optimization_platform_interface.dart';

/// 禁用电池优化流程的结果状态。
enum OptimizationOutcomeStatus {
  /// 当前应用已处于未受电池优化限制状态。
  alreadyDisabled,

  /// 用户完成授权后，应用已成功加入电池优化白名单。
  disabledAfterPrompt,

  /// 无法直接完成授权，已打开系统设置页供用户手动处理。
  settingsOpened,

  /// 当前平台或系统版本不支持相关能力。
  unsupported,

  /// 请求或跳转流程执行失败。
  failed,
}

/// [BanBatteryOptimization.ensureOptimizationDisabledDetailed] 返回的结果对象。
class OptimizationOutcome {
  const OptimizationOutcome({
    required this.status,
    required this.isOptimizationDisabled,
  });

  /// 禁用流程结束后的最终状态。
  final OptimizationOutcomeStatus status;

  /// 当前调用结束时，应用是否已不再受电池优化限制。
  final bool isOptimizationDisabled;

  /// 只要不是显式失败状态，就返回 true。
  bool get succeeded => status != OptimizationOutcomeStatus.failed;
}

/// 当前设备电池限制相关信息快照。
class BatteryRestrictionSnapshot {
  const BatteryRestrictionSnapshot({
    required this.isSupported,
    required this.androidSdkInt,
    required this.manufacturer,
    required this.isBatteryOptimizationEnabled,
    required this.isPowerSaveModeOn,
    required this.canOpenAutoStartSettings,
  });

  factory BatteryRestrictionSnapshot.fromMap(Map<String, dynamic> map) {
    return BatteryRestrictionSnapshot(
      isSupported: _asBool(map['isSupported']),
      androidSdkInt: _asInt(map['androidSdkInt']),
      manufacturer: _asString(map['manufacturer']),
      isBatteryOptimizationEnabled: _asBool(
        map['isBatteryOptimizationEnabled'],
      ),
      isPowerSaveModeOn: _asBool(map['isPowerSaveModeOn']),
      canOpenAutoStartSettings: _asBool(map['canOpenAutoStartSettings']),
    );
  }

  const BatteryRestrictionSnapshot.unsupported()
    : isSupported = false,
      androidSdkInt = null,
      manufacturer = 'unknown',
      isBatteryOptimizationEnabled = false,
      isPowerSaveModeOn = false,
      canOpenAutoStartSettings = false;

  /// 当前平台是否支持电池优化相关接口。
  final bool isSupported;

  /// 当前 Android SDK 版本，无法获取时为 null。
  final int? androidSdkInt;

  /// 系统返回的设备厂商名称。
  final String manufacturer;

  /// 当前应用是否仍然受到电池优化限制。
  final bool isBatteryOptimizationEnabled;

  /// 当前是否开启省电模式。
  final bool isPowerSaveModeOn;

  /// 是否大概率可以打开厂商自启动设置页。
  final bool canOpenAutoStartSettings;

  static bool _asBool(dynamic value) => value is bool ? value : false;

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _asString(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return 'unknown';
  }
}

/// 对外暴露的 Android 电池优化相关能力。
class BanBatteryOptimization {
  /// 当前 API 使用的平台实现实例。
  static BanBatteryOptimizationPlatform get _platform =>
      BanBatteryOptimizationPlatform.instance;

  /// 获取当前设备的电池限制诊断信息。
  static Future<BatteryRestrictionSnapshot>
  getBatteryRestrictionSnapshot() async {
    try {
      final map = await _platform.getBatteryRestrictionSnapshot();
      return BatteryRestrictionSnapshot.fromMap(map);
    } on PlatformException {
      return const BatteryRestrictionSnapshot.unsupported();
    } catch (_) {
      return const BatteryRestrictionSnapshot.unsupported();
    }
  }

  /// 返回当前应用是否仍启用了系统电池优化。
  static Future<bool> isBatteryOptimizationEnabled() async {
    try {
      return await _platform.isBatteryOptimizationEnabled();
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 尝试弹出系统授权框，将应用加入电池优化白名单。
  static Future<void> requestDisableBatteryOptimization() async {
    try {
      await _platform.requestDisableBatteryOptimization();
    } catch (_) {}
  }

  /// 打开系统电池优化设置页。
  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await _platform.openBatteryOptimizationSettings();
    } catch (_) {}
  }

  /// 尝试打开厂商自启动或后台管理设置页。
  static Future<bool> openAutoStartSettings() async {
    try {
      return await _platform.openAutoStartSettings();
    } catch (_) {
      return false;
    }
  }

  /// 若已关闭限制，或已成功发起授权/跳转设置，则返回 true。
  static Future<bool> ensureOptimizationDisabled({
    bool openSettingsIfDirectRequestNotPossible = true,
  }) async {
    final outcome = await ensureOptimizationDisabledDetailed(
      openSettingsIfDirectRequestNotPossible:
          openSettingsIfDirectRequestNotPossible,
    );
    return outcome.succeeded;
  }

  /// 返回带明确状态的禁用电池优化流程结果。
  static Future<OptimizationOutcome> ensureOptimizationDisabledDetailed({
    bool openSettingsIfDirectRequestNotPossible = true,
  }) async {
    final snapshot = await getBatteryRestrictionSnapshot();
    if (!snapshot.isSupported) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.unsupported,
        isOptimizationDisabled: true,
      );
    }

    if (!snapshot.isBatteryOptimizationEnabled) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.alreadyDisabled,
        isOptimizationDisabled: true,
      );
    }

    try {
      try {
        final disabled = await _platform
            .requestDisableBatteryOptimizationWithResult();
        if (disabled) {
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.disabledAfterPrompt,
            isOptimizationDisabled: true,
          );
        }
      } on UnimplementedError {
        await _platform.requestDisableBatteryOptimization();
      }

      final nowOptimized = await isBatteryOptimizationEnabled();
      if (!nowOptimized) {
        return const OptimizationOutcome(
          status: OptimizationOutcomeStatus.disabledAfterPrompt,
          isOptimizationDisabled: true,
        );
      }
    } on PlatformException {
      if (openSettingsIfDirectRequestNotPossible) {
        try {
          await _platform.openBatteryOptimizationSettings();
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.settingsOpened,
            isOptimizationDisabled: false,
          );
        } catch (_) {
          return const OptimizationOutcome(
            status: OptimizationOutcomeStatus.failed,
            isOptimizationDisabled: false,
          );
        }
      }
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.failed,
        isOptimizationDisabled: false,
      );
    } catch (_) {
      return const OptimizationOutcome(
        status: OptimizationOutcomeStatus.failed,
        isOptimizationDisabled: false,
      );
    }

    if (openSettingsIfDirectRequestNotPossible) {
      try {
        await _platform.openBatteryOptimizationSettings();
        return const OptimizationOutcome(
          status: OptimizationOutcomeStatus.settingsOpened,
          isOptimizationDisabled: false,
        );
      } catch (_) {}
    }

    return const OptimizationOutcome(
      status: OptimizationOutcomeStatus.failed,
      isOptimizationDisabled: false,
    );
  }
}
