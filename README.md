# ban_battery_optimization

A Flutter plugin for Android battery optimization checks, whitelist requests, and OEM auto-start / background management settings shortcuts.

[中文文档](README.zh-CN.md)

---

## Features

- Check whether the current app is still restricted by Android battery optimization.
- Request the system battery optimization whitelist.
- Open the system battery optimization settings page.
- Try to open OEM auto-start / background management settings pages.
- Get a diagnostic snapshot of current battery restrictions.
- Provide a guided flow: **check → request whitelist → open system settings → open OEM settings**.

---

## Supported manufacturers

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

OEM settings shortcuts are best-effort. Some pages may change or become unavailable on different ROM or Android versions.

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ban_battery_optimization: ^1.0.0
```

Then run:

```sh
flutter pub get
```

---

## Android permissions

The plugin declares this permission:

```xml
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

You may also keep the same permission in your app's `AndroidManifest.xml` if needed.

The plugin also declares Android 11+ `queries` package visibility entries to check whether supported OEM auto-start / background management settings pages are available.

The `queries` list only contains supported OEM system manager packages. It does not use `QUERY_ALL_PACKAGES`.

---

## Usage

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
      // Show follow-up instructions after the system settings page opens.
    }
  }

  final opened = await BanBatteryOptimization.openAutoStartSettings();
  if (!opened) {
    // Show fallback in-app instructions when no OEM settings page is available.
  }

  debugPrint(snapshot.manufacturer);
}
```

---

## Core APIs

### `getBatteryRestrictionSnapshot()`

Returns a battery restriction snapshot for the current device, including:

- Capability support status
- Android SDK version
- Manufacturer name
- Whether battery optimization is still enabled
- Whether power save mode is enabled
- Whether an OEM auto-start settings page is available

### `isBatteryOptimizationEnabled()`

Returns whether the current app is still restricted by system battery optimization.

### `requestDisableBatteryOptimization()`

Tries to show the system prompt that asks the user to add the app to the battery optimization whitelist.

### `openBatteryOptimizationSettings()`

Opens the system battery optimization settings page.

### `openAutoStartSettings()`

Tries to open an OEM auto-start / background management settings page.

- Returns `true` when a settings page was launched.
- Returns `false` when no page is available or launching fails.

### `ensureOptimizationDisabledDetailed()`

Returns a detailed guided-flow result:

- `alreadyDisabled`: the app was already unrestricted
- `disabledAfterPrompt`: the app was whitelisted after the system prompt
- `settingsOpened`: the system settings page was opened for manual action
- `unsupported`: the current platform or system version is unsupported
- `failed`: the flow failed

### `ensureOptimizationDisabled()`

Returns a simplified boolean result.

- `true`: no explicit failure occurred
- `false`: the flow failed

---

## Android notes

- This plugin can only guide users to system or OEM settings pages. It cannot silently disable battery optimization.
- Android 6.0+ introduced Doze and battery optimization restrictions.
- OEM settings page paths depend on ROM implementations and may change over time.

---

## Recommendations

- Explain the reason before opening settings, such as background audio, notifications, or scheduled reminders.
- Provide fallback instructions when `openAutoStartSettings()` returns `false`.
- If a settings page was opened but the user did not grant permission, provide concise in-app guidance.

---

## Changelog

See `CHANGELOG.md`.

---

## License

MIT
