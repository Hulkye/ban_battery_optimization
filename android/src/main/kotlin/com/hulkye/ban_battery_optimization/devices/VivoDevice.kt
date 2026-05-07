package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class VivoDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("vivo", "iqoo")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.vivo.permissionmanager",
      "com.vivo.permissionmanager.activity.BgStartUpManagerActivity",
    ),
    componentIntent(
      "com.iqoo.secure",
      "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity",
    ),
  )
}
