package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class LetvDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("letv", "leeco")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.letv.android.letvsafe",
      "com.letv.android.letvsafe.AutobootManageActivity",
    ),
  )
}
