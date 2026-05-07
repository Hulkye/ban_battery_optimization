package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class MotorolaDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("motorola", "moto")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.motorola.ccc",
      "com.motorola.ccc.settings.optimize.ProcessManager",
    ),
  )
}
