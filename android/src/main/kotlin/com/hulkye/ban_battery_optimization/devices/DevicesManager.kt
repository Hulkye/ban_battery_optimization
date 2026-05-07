package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

object DevicesManager {
  private val devices: List<DeviceBase> = listOf(
    AsusDevice(),
    HtcDevice(),
    HuaweiDevice(),
    HonorDevice(),
    LenovoDevice(),
    LetvDevice(),
    MeizuDevice(),
    MotorolaDevice(),
    NokiaDevice(),
    OppoDevice(),
    SamsungDevice(),
    TranssionDevice(),
    VivoDevice(),
    XiaomiDevice(),
    ZteDevice(),
  )

  fun currentDevice(): DeviceBase? {
    val manufacturer = Build.MANUFACTURER.orEmpty()
    return devices.firstOrNull { it.isThatRom(manufacturer) }
  }

  fun canOpenAutoStartSettings(context: Context): Boolean {
    val packageManager = context.packageManager
    return autoStartCandidates(context, includeGenericFallbacks = false).any {
      it.resolveActivity(packageManager) != null
    }
  }

  fun openAutoStartSettings(context: Context): Boolean {
    return autoStartCandidates(context, includeGenericFallbacks = true).any {
      tryStartActivity(context, it)
    }
  }

  private fun autoStartCandidates(
    context: Context,
    includeGenericFallbacks: Boolean,
  ): List<Intent> {
    val candidates = mutableListOf<Intent>()
    val device = currentDevice()
    if (device != null) {
      candidates += device.getAutoStartIntents(context)
      candidates += device.getPowerSavingIntents(context)
    }

    if (includeGenericFallbacks) {
      candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
        data = android.net.Uri.parse("package:${context.packageName}")
      }
      candidates += Intent(Settings.ACTION_SETTINGS)
    }

    return candidates
  }

  private fun tryStartActivity(context: Context, intent: Intent): Boolean {
    return try {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      context.startActivity(intent)
      true
    } catch (_: Exception) {
      false
    }
  }
}
