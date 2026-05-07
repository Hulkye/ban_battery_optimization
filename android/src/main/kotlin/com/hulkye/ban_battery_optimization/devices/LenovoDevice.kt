package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class LenovoDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("lenovo")

  override fun getPowerSavingIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.lenovo.powersetting",
      "com.lenovo.powersetting.ui.Settings\$HighPowerApplicationsActivity",
    ),
  )
}