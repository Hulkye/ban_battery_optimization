package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class SamsungDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("samsung")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.samsung.android.lool",
      "com.samsung.android.sm.ui.battery.BatteryActivity",
    ),
    componentIntent(
      "com.samsung.android.sm",
      "com.samsung.android.sm.ui.battery.BatteryActivity",
    ),
    componentIntent(
      "com.samsung.android.sm",
      "com.samsung.android.sm.app.dashboard.SmartManagerDashBoardActivity",
    ),
  )
}
