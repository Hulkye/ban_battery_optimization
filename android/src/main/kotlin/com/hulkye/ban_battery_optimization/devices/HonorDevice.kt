package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class HonorDevice : HuaweiDevice() {
  override val manufacturerNames = setOf("honor")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.hihonor.systemmanager",
      "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
    ),
  )
}
