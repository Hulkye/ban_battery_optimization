package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class AsusDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("asus")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.asus.mobilemanager",
      "com.asus.mobilemanager.MainActivity",
    ),
  )
}
