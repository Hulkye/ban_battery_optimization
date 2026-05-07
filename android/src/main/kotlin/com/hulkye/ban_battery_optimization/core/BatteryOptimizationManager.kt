package com.hulkye.ban_battery_optimization.core

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import com.hulkye.ban_battery_optimization.devices.DevicesManager

/** 电池优化相关原生能力的统一封装。 */
class BatteryOptimizationManager(private val context: Context) {
  /** 返回当前应用是否仍受系统电池优化限制。 */
  fun isBatteryOptimizationEnabled(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
    return !isOptimizationDisabled()
  }

  /** 返回当前应用是否已被系统加入电池优化白名单。 */
  fun isOptimizationDisabled(): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
    return powerManager?.isIgnoringBatteryOptimizations(context.packageName) ?: false
  }

  /** 发起系统白名单授权请求。 */
  fun requestDisableBatteryOptimization(activity: Activity?) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
    startActivity(activity, intent)
  }

  /** 发起带回调结果的系统白名单授权请求。 */
  fun requestDisableBatteryOptimizationForResult(activity: Activity, requestCode: Int) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
    activity.startActivityForResult(intent, requestCode)
  }

  /** 打开系统电池优化设置页。 */
  fun openBatteryOptimizationSettings(activity: Activity?) {
    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
    } else {
      appDetailsIntent()
    }
    startActivity(activity, intent)
  }

  /** 打开当前应用详情设置页。 */
  fun openAppDetailsSettings(activity: Activity?) {
    startActivity(activity, appDetailsIntent())
  }

  /** 尝试打开厂商自启动或后台管理设置页。 */
  fun openAutoStartSettings(): Boolean {
    return DevicesManager.openAutoStartSettings(context)
  }

  /** 构建设备当前电池限制状态快照。 */
  fun buildBatteryRestrictionSnapshot(): Map<String, Any> {
    val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
    return hashMapOf(
      "isSupported" to supported,
      "androidSdkInt" to Build.VERSION.SDK_INT,
      "manufacturer" to Build.MANUFACTURER.orEmpty(),
      "isBatteryOptimizationEnabled" to if (supported) isBatteryOptimizationEnabled() else false,
      "isPowerSaveModeOn" to (powerManager?.isPowerSaveMode ?: false),
      "canOpenAutoStartSettings" to DevicesManager.canOpenAutoStartSettings(context),
    )
  }

  /** 优先通过 Activity 启动页面，失败时回退到应用详情页。 */
  private fun startActivity(activity: Activity?, intent: Intent) {
    try {
      activity?.startActivity(intent) ?: run {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
      }
    } catch (_: Exception) {
      try {
        val fallback = appDetailsIntent().apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        context.startActivity(fallback)
      } catch (_: Exception) {}
    }
  }

  /** 生成当前应用详情设置页的 Intent。 */
  private fun appDetailsIntent(): Intent {
    return Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
  }
}
