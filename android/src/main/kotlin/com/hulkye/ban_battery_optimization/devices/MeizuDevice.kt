package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class MeizuDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("meizu")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.meizu.safe",
      "com.meizu.safe.permission.SmartBGActivity",
    ),
  )
}
