package com.hulkye.ban_battery_optimization

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import com.hulkye.ban_battery_optimization.core.BatteryOptimizationManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** Flutter 插件入口，负责接收 Dart 层调用并转发到原生实现。 */
class BanBatteryOptimizationPlugin :
  FlutterPlugin,
  MethodChannel.MethodCallHandler,
  ActivityAware,
  PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private lateinit var manager: BatteryOptimizationManager
  private var activity: Activity? = null
  private var pendingResult: MethodChannel.Result? = null
  private val requestIgnoreBatteryCode = 9101

  /** 绑定到 FlutterEngine 时初始化通道和核心管理器。 */
  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    manager = BatteryOptimizationManager(context)
    channel = MethodChannel(binding.binaryMessenger, "ban_battery_optimization")
    channel.setMethodCallHandler(this)
  }

  /** 从 FlutterEngine 分离时移除通道处理器。 */
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /** 绑定到 Activity 时注册结果监听。 */
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  /** Activity 分离时清理引用。 */
  override fun onDetachedFromActivity() {
    activity = null
  }

  /** 配置变更后重新绑定 Activity。 */
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  /** 配置变更导致 Activity 分离时清理引用。 */
  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  /** 分发 Dart 层发起的方法调用。 */
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "isBatteryOptimizationEnabled" -> result.success(
        manager.isBatteryOptimizationEnabled(),
      )

      "requestDisableBatteryOptimization" -> {
        manager.requestDisableBatteryOptimization(activity)
        result.success(null)
      }

      "requestDisableBatteryOptimizationWithResult" -> {
        requestDisableBatteryOptimizationWithResult(result)
      }

      "openBatteryOptimizationSettings" -> {
        manager.openBatteryOptimizationSettings(activity)
        result.success(null)
      }

      "openAutoStartSettings" -> result.success(manager.openAutoStartSettings())

      "getBatteryRestrictionSnapshot" -> result.success(
        manager.buildBatteryRestrictionSnapshot(),
      )

      else -> result.notImplemented()
    }
  }

  /** 处理系统授权页返回结果。 */
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != requestIgnoreBatteryCode) return false

    val result = pendingResult
    pendingResult = null
    result?.success(
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        manager.isOptimizationDisabled()
      } else {
        true
      },
    )
    return true
  }

  /** 发起带结果的系统白名单授权请求。 */
  private fun requestDisableBatteryOptimizationWithResult(result: MethodChannel.Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      result.success(true)
      return
    }

    if (pendingResult != null) {
      result.error("in_progress", "Another request is in progress", null)
      return
    }

    val currentActivity = activity
    if (currentActivity == null) {
      result.success(manager.isOptimizationDisabled())
      return
    }

    pendingResult = result
    try {
      manager.requestDisableBatteryOptimizationForResult(
        currentActivity,
        requestIgnoreBatteryCode,
      )
    } catch (_: Exception) {
      pendingResult = null
      result.success(manager.isOptimizationDisabled())
    }
  }
}
