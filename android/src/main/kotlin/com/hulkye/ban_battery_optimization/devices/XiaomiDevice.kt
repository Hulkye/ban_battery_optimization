package com.hulkye.ban_battery_optimization.devices

import android.content.Context
import android.content.Intent

class XiaomiDevice : DeviceAbstract() {
  override val manufacturerNames = setOf("xiaomi", "redmi", "poco")

  override fun getAutoStartIntents(context: Context): List<Intent> = listOf(
    componentIntent(
      "com.miui.securitycenter",
      "com.miui.permcenter.autostart.AutoStartManagementActivity",
    ),
    componentIntent(
      "com.miui.securitycenter",
      "com.miui.permcenter.permissions.PermissionsEditorActivity",
    ),
  )
}
