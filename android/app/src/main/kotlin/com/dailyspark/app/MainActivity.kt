package com.dailyspark.app

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent 
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    companion object {
        var pendingLaunchAlarmId: String? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        applyLockScreenFlags() 
        AlarmRingingService.createNotificationChannel(this)
        captureAlarmIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        captureAlarmIntent(intent)
        val id = intent.getStringExtra("AlarmReceiver.EXTRA_ALARM_ID")
        if (intent.action == "AlarmSchedule.ACTION_LAUNCH_RING" && id != null) {
            AlarmSchedulerPlugin.sendAlarmToFlutter(id)
        }
    }

    private fun captureAlarmIntent(intent: Intent) {
        if (intent.action == "AlarmSchedule.ACTION_LAUNCH_RING") {
            pendingLaunchAlarmId = intent.getStringExtra("AlarmReceiver.EXTRA_ALARM_ID")
        }
    }

   
    private fun applyLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AlarmSchedulerPlugin())
    }
} 
