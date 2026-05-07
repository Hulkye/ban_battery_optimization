package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

/** ZTE 设备的自启动与省电设置入口。 */
class ZteDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("zte", "nubia")

  /** 返回 ZTE 设备的自启动管理设置页。 */
  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.zte.heartyservice",
      "com.zte.heartyservice.autorun.AppAutoRunManager",
    ),
    componentIntent(
      "com.zte.heartyservice",
      "com.zte.heartyservice.setting.BackgroundAppManagementActivity",
    ),
    componentIntent(
      "com.zte.heartyservice",
      "com.zte.heartyservice.setting.AppBackgroundManagementActivity",
    ),
  )

  /** 返回 ZTE 设备的省电管理设置页。 */
  override fun getPowerSavingIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.zte.heartyservice",
      "com.zte.heartyservice.setting.ClearAppSettingsActivity",
    ),
  )
}
