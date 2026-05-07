package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class OppoDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("oppo", "realme", "oneplus")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.coloros.safecenter",
      "com.coloros.safecenter.startupapp.StartupAppListActivity",
    ),
    componentIntent(
      "com.oppo.safe",
      "com.oppo.safe.permission.startup.StartupAppListActivity",
    ),
    componentIntent(
      "com.coloros.safecenter",
      "com.coloros.safecenter.permission.startup.StartupAppListActivity",
    ),
    componentIntent(
      "com.oneplus.security",
      "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity",
    ),
    componentIntent(
      "com.oneplus.security",
      "com.oneplus.security.chainlaunch.view.ChainLaunchSettings",
    ),
  )
}
