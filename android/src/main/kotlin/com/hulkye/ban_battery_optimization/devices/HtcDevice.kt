package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

/** HTC 设备的后台省电设置入口。 */
class HtcDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("htc")

  /** 返回 HTC 设备的省电管理设置页。 */
  override fun getPowerSavingIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.htc.pitroad",
      "com.htc.pitroad.landingpage.activity.LandingPageActivity",
    ),
  )
}
