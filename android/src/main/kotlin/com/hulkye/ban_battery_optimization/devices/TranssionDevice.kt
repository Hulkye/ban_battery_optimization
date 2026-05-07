package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class TranssionDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("infinix", "tecno", "itel")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.transsion.phonemaster",
      "com.cyin.himgr.autostart.AutoStartActivity",
    ),
  )
}