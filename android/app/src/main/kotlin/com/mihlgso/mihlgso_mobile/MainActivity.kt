package com.mihlgso.mihlgso_mobile

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Saves exported admin data (Payments/Donations/Applications: CSV/Excel/PDF)
 * straight into the device's real, user-visible Downloads folder — no share
 * sheet, no save-location picker — then posts a system notification (like a
 * normal browser "Download complete") that opens the file when tapped.
 *
 * On Android 10+ the save goes through MediaStore.Downloads (no permission
 * needed); on 9 and below it writes directly to the public Downloads
 * directory, which needs WRITE_EXTERNAL_STORAGE (declared with
 * maxSdkVersion=28 in the manifest, since scoped storage on 10+ makes it
 * unnecessary). The notification itself needs POST_NOTIFICATIONS on
 * Android 13+; if that's not granted the file is still saved, it just won't
 * show a notification for it.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "mihlgso/downloads"
    private val notificationChannelId = "downloads"
    private val storagePermissionCode = 9821
    private val notificationPermissionCode = 9822

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannel()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val name = call.argument<String>("name")
                val bytes = call.argument<ByteArray>("bytes")
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                if (name == null || bytes == null) {
                    result.error("BAD_ARGS", "name and bytes are required", null)
                    return@setMethodCallHandler
                }
                try {
                    val uri = saveToDownloads(name, bytes, mimeType)
                    showDownloadNotification(name, uri, mimeType)
                    result.success(uri.toString())
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            notificationChannelId,
            "Downloads",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Notifies when an exported file finishes saving to Downloads."
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    private fun saveToDownloads(name: String, bytes: ByteArray, mimeType: String): Uri {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = applicationContext.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Could not create a Downloads entry")
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("Could not open the Downloads entry for writing")
            return uri
        }

        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
                storagePermissionCode,
            )
            throw IllegalStateException("Storage permission was just requested — please try again")
        }

        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists()) downloadsDir.mkdirs()
        val file = File(downloadsDir, name)
        FileOutputStream(file).use { it.write(bytes) }
        // A raw file:// Uri would crash on API 24+ (FileUriExposedException) if
        // handed to another app via an Intent, so route it through this app's
        // FileProvider (see res/xml/file_paths.xml) for a shareable content:// Uri.
        return FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
    }

    private fun showDownloadNotification(name: String, uri: Uri, mimeType: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                notificationPermissionCode,
            )
            return
        }

        val openIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimeType)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            name.hashCode(),
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(this, notificationChannelId)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle("Download complete")
            .setContentText(name)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(this).notify(name.hashCode(), notification)
    }
}
