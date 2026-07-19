package com.dailyspark.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat

/**
 * Foreground service that owns audio + vibration while an alarm is
 * ringing, and launches the full-screen ringing Activity over the
 * lock screen. Kept alive independently of the Flutter engine so
 * ringing continues even if the UI hasn't attached yet.
 */
class AlarmRingingService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getStringExtra(AlarmReceiver.EXTRA_ALARM_ID) ?: return START_NOT_STICKY
        val label = intent.getStringExtra(AlarmReceiver.EXTRA_LABEL) ?: ""
        val soundId = intent.getStringExtra(AlarmReceiver.EXTRA_SOUND_ID) ?: "default"
        val vibrate = intent.getBooleanExtra(AlarmReceiver.EXTRA_VIBRATE, true)

        startForeground(NOTIFICATION_ID, buildNotification(alarmId, label))
        launchRingingActivity(alarmId, label, soundId)
        playSound(soundId)
        if (vibrate) startVibration()

        return START_STICKY
    }

    private fun launchRingingActivity(alarmId: String, label: String, soundId: String) {
        val activityIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP,
            )
            action = AlarmScheduler.ACTION_ALARM_FIRE
            putExtra(AlarmReceiver.EXTRA_ALARM_ID, alarmId)
            putExtra(AlarmReceiver.EXTRA_LABEL, label)
            putExtra(AlarmReceiver.EXTRA_SOUND_ID, soundId)
        }
        startActivity(activityIntent)
    }

  private fun buildNotification(alarmId: String, label: String): Notification {
    val activityIntent = Intent(this, MainActivity::class.java).apply {
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        action = "AlarmSchedule.ACTION_LAUNCH_RING"
        putExtra("AlarmReceiver.EXTRA_ALARM_ID", alarmId)
    }

    val fullScreenPendingIntent = PendingIntent.getActivity(
        this,
        alarmId.hashCode(),
        activityIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    return NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle(label.ifEmpty { "Alarm" })
        .setContentText("Tap to open alarm screen")
        .setSmallIcon(R.mipmap.ic_launcher)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setCategory(NotificationCompat.CATEGORY_ALARM)
        .setOngoing(true)
        .setContentIntent(fullScreenPendingIntent)
        .setFullScreenIntent(fullScreenPendingIntent, true)
        .build()
}

    private fun playSound(soundId: String) {
        mediaPlayer?.release()
        val resId = resources.getIdentifier(soundId, "raw", packageName)
        val resolvedId = if (resId != 0) resId else resources.getIdentifier(
            "morning_chimes", "raw", packageName,
        )
        if (resolvedId == 0) return
        mediaPlayer = MediaPlayer.create(this, resolvedId)?.apply {
            isLooping = true
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            start()
        }
    }

    private fun startVibration() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vm.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        val pattern = longArrayOf(0, 500, 500)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 1))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 1)
        }
    }

    private fun stopAll() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        vibrator?.cancel()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopAll()
        super.onDestroy()
    }

    companion object {
        const val CHANNEL_ID = "daily_spark_alarm_channel"
        const val NOTIFICATION_ID = 42

        fun createNotificationChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val manager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Daily Spark Alarms",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "Full-screen morning alarm notifications"
                }
                manager.createNotificationChannel(channel)
            }
        }

        /** Stops ringing for the given alarm id, called on Dismiss/Snooze. */
        fun stopRinging(context: Context, id: String) {
            context.stopService(Intent(context, AlarmRingingService::class.java))
        }
    }
}
