package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class NokiaDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("nokia")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.evenwell.powersaving.g3",
      "com.evenwell.powersaving.g3.exception.PowerSaverExceptionActivity",
    ),
  )
}
