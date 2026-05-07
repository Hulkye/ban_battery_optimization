package com.hulkye.ban_battery_optimization.devices

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/** 厂商设备能力的抽象基类，提供通用默认实现。 */
abstract class DeviceAbstract : DeviceBase {
  /** 判断当前厂商名是否命中该设备实现。 */
  override fun isThatRom(manufacturer: String): Boolean {
    val normalized = manufacturer.lowercase().trim()
    return manufacturerNames.any { normalized == it || normalized.contains(it) }
  }

  /** 默认不提供自启动设置页。 */
  override fun getAutoStartIntents(context: Context): List<Intent> = emptyList()

  /** 默认不提供额外省电设置页。 */
  override fun getPowerSavingIntents(context: Context): List<Intent> = emptyList()

  /** 返回系统电池优化设置页的 Intent。 */
  override fun getDozeIntent(context: Context): Intent? {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || isDozeModeNotNecessary(context)) {
      return null
    }

    return Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
  }

  /** 返回当前设备是否无需再处理 Doze 白名单。 */
  override fun isDozeModeNotNecessary(context: Context): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
    return powerManager?.isIgnoringBatteryOptimizations(context.packageName) ?: true
  }

  /** 构建显式组件 Intent。 */
  protected fun componentIntent(packageName: String, className: String): Intent {
    return Intent().apply {
      component = ComponentName(packageName, className)
    }
  }

  /** 构建应用详情设置页 Intent。 */
  protected fun appDetailsIntent(context: Context): Intent {
    return Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
      data = Uri.parse("package:${context.packageName}")
    }
  }
}
