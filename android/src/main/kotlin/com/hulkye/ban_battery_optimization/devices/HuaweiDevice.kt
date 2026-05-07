package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

open class HuaweiDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("huawei")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.huawei.systemmanager",
      "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
    ),
    componentIntent(
      "com.huawei.systemmanager",
      "com.huawei.systemmanager.optimize.bootstart.BootStartActivity",
    ),
  )
}
