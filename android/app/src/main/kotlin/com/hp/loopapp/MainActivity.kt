package com.hp.loopapp

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "loopin/reminders"
    private val studyFilesChannelName = "loopin/study_files"
    private val studyFileRequestCode = 7101
    private var pendingStudyFileResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf("android.permission.POST_NOTIFICATIONS"), 7001)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "schedule" -> {
                    scheduleReminder(call.argument<String>("id"), call.argument<String>("title"), call.argument<String>("description"), call.argument<Long>("triggerAtMillis"))
                    result.success(null)
                }
                "cancel" -> {
                    cancelReminder(call.argument<String>("id"))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, studyFilesChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickTextNote" -> {
                    pendingStudyFileResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "text/*"
                    }
                    startActivityForResult(intent, studyFileRequestCode)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url.isNullOrBlank()) {
                        result.error("INVALID_URL", "A URL is required.", null)
                    } else {
                        try {
                            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                            result.success(null)
                        } catch (error: Exception) {
                            result.error("URL_OPEN_FAILED", error.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != studyFileRequestCode) return
        val result = pendingStudyFileResult ?: return
        pendingStudyFileResult = null
        if (resultCode != RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }
        val uri = data.data ?: run {
            result.success(null)
            return
        }
        try {
            val content = contentResolver.openInputStream(uri)?.use { stream ->
                val bytes = stream.readBytes()
                if (bytes.size > 5 * 1024 * 1024) {
                    throw IllegalArgumentException("Note files must be 5 MB or smaller.")
                }
                bytes.toString(Charsets.UTF_8)
            }.orEmpty()
            val name = queryDisplayName(uri) ?: "Imported note"
            result.success(mapOf("name" to name, "content" to content))
        } catch (error: Exception) {
            result.error("FILE_READ_FAILED", error.message, null)
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (it.moveToFirst() && index >= 0) return it.getString(index)
        }
        return null
    }

    private fun reminderId(id: String?): Int = id.orEmpty().hashCode() and 0x7fffffff

    private fun pendingIntent(id: String?, title: String? = null, description: String? = null): PendingIntent {
        val intent = Intent(this, ReminderReceiver::class.java).apply {
            putExtra(ReminderReceiver.EXTRA_ID, reminderId(id))
            putExtra(ReminderReceiver.EXTRA_TITLE, title)
            putExtra(ReminderReceiver.EXTRA_DESCRIPTION, description)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        return PendingIntent.getBroadcast(this, reminderId(id), intent, flags)
    }

    private fun scheduleReminder(id: String?, title: String?, description: String?, triggerAtMillis: Long?) {
        if (id == null || triggerAtMillis == null || triggerAtMillis <= System.currentTimeMillis()) return
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val alarmIntent = pendingIntent(id, title, description)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, alarmIntent)
        } else {
            alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, alarmIntent)
        }
    }

    private fun cancelReminder(id: String?) {
        if (id == null) return
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent(id))
    }
}
