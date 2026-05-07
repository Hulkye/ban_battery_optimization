package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

interface DeviceBase {
  val manufacturerNames: Set<String>

  fun isThatRom(manufacturer: String): Boolean

  fun getAutoStartIntents(context: Context): List<Intent>

  fun getPowerSavingIntents(context: Context): List<Intent>

  fun getDozeIntent(context: Context): Intent?

  fun isDozeModeNotNecessary(context: Context): Boolean
}
