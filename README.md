# ban_battery_optimization

Android 电池优化检测、系统白名单申请，以及厂商自启动 / 后台管理设置跳转的 Flutter 插件。

---

## 功能

- 检查当前应用是否仍受系统电池优化限制。
- 请求系统将应用加入电池优化白名单。
- 打开系统电池优化设置页。
- 尝试打开厂商自启动 / 后台管理设置页。
- 获取当前设备的电池限制诊断信息。
- 提供一键引导流程：**检测 → 申请白名单 → 打开系统设置 → 打开厂商设置**。

---

## 已支持厂商

- Xiaomi / Redmi / Poco
- Oppo / Realme / OnePlus
- Vivo / iQOO
- Huawei
- Honor
- Samsung
- Asus
- Meizu
- Letv / LeEco
- Nokia
- Motorola
- HTC
- ZTE / Nubia
- Lenovo
- Infinix / Tecno / Itel

厂商设置页能力为 best-effort，不同 ROM 和系统版本可能失效。

---

## 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  ban_battery_optimization: ^1.0.0
```

然后执行 `flutter pub get`。

---

## Android 权限

插件已声明以下权限：

```xml
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

如需自行声明，也可在宿主应用 `AndroidManifest.xml` 中保留同名权限。

插件还声明了 Android 11+ 的 `queries` 包可见性，用于检测厂商自启动 / 后台管理设置页是否可用。

`queries` 只包含已支持厂商的系统管理组件包名，不使用 `QUERY_ALL_PACKAGES`。

---

## 使用示例

```dart
import 'dart:io';

import 'package:ban_battery_optimization/ban_battery_optimization.dart';

Future<void> checkBatteryOptimization() async {
  if (!Platform.isAndroid) {
    return;
  }

  final snapshot =
      await BanBatteryOptimization.getBatteryRestrictionSnapshot();

  final enabled =
      await BanBatteryOptimization.isBatteryOptimizationEnabled();

  if (enabled) {
    final outcome =
        await BanBatteryOptimization.ensureOptimizationDisabledDetailed();

    if (outcome.status == OptimizationOutcomeStatus.settingsOpened) {
      // 用户已被引导到系统设置页，可在界面上继续提示后续操作。
    }
  }

  final opened = await BanBatteryOptimization.openAutoStartSettings();
  if (!opened) {
    // 可在这里展示应用内说明页。
  }

  // snapshot 可用于上报、日志或界面提示。
  debugPrint(snapshot.manufacturer);
}
```

---

## 核心 API

### `getBatteryRestrictionSnapshot()`

返回当前设备电池限制快照，包含：

- 是否支持当前能力
- Android SDK 版本
- 厂商名称
- 是否仍受电池优化限制
- 是否开启省电模式
- 是否可打开厂商自启动设置页

### `isBatteryOptimizationEnabled()`

返回当前应用是否仍受系统电池优化限制。

### `requestDisableBatteryOptimization()`

尝试弹出系统授权框，请求将应用加入白名单。

### `openBatteryOptimizationSettings()`

打开系统电池优化设置页。

### `openAutoStartSettings()`

尝试打开厂商自启动 / 后台管理设置页。

- 返回 `true`：成功发起跳转。
- 返回 `false`：当前设备无可用页面或跳转失败。

### `ensureOptimizationDisabledDetailed()`

返回带状态的完整引导结果：

- `alreadyDisabled`：原本就未受限制
- `disabledAfterPrompt`：弹框授权后已成功加入白名单
- `settingsOpened`：已打开系统设置页，等待用户手动处理
- `unsupported`：当前平台或系统版本不支持
- `failed`：流程执行失败

### `ensureOptimizationDisabled()`

返回简化布尔值结果。

- `true`：未出现显式失败
- `false`：流程失败

---

## Android 说明

- 该插件只能引导用户进入系统页面或厂商页面，不能静默关闭电池优化。
- Android 6.0 以上才存在 Doze / 电池优化限制概念。
- 厂商设置页路径依赖 ROM 实现，可能随系统更新变化。

---

## 使用建议

- 在跳转前向用户说明用途，例如后台语音、消息保活、定时任务提醒。
- 对 `openAutoStartSettings()` 返回 `false` 的情况做好兜底提示。
- 若已打开设置页但用户未授权，建议在应用内提供简短图文指引。

---

## 变更记录

详见 `CHANGELOG.md`。

---

## 许可证

MIT
