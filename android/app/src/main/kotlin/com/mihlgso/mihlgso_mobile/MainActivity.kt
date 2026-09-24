package com.mihlgso.mihlgso_mobile

import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Saves exported admin data (Payments/Donations/Applications: CSV/Excel/PDF)
 * straight into the device's real, user-visible Downloads folder — no share
 * sheet, no save-location picker. On Android 10+ this goes through
 * MediaStore.Downloads (no permission needed); on 9 and below it writes
 * directly to the public Downloads directory, which needs
 * WRITE_EXTERNAL_STORAGE (declared with maxSdkVersion=28 in the manifest,
 * since scoped storage on 10+ makes it unnecessary and Google flags apps
 * that request it without a maxSdkVersion cap).
 */
class MainActivity : FlutterActivity() {
    private val channelName = "mihlgso/downloads"
    private val storagePermissionCode = 9821

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
                    result.success(saveToDownloads(name, bytes, mimeType))
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(name: String, bytes: ByteArray, mimeType: String): String {
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
            return uri.toString()
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
        return file.absolutePath
    }
}
