package com.example.invite_sender

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.invite_sender/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendCard" -> {
                        val cardPath = call.argument<String>("cardPath")
                        val phone = call.argument<String>("phone")
                        val caption = call.argument<String>("caption")

                        if (cardPath == null || phone == null || caption == null) {
                            result.error("BAD_ARGS", "Missing cardPath/phone/caption", null)
                            return@setMethodCallHandler
                        }

                        try {
                            sendCardToGuestOnWhatsApp(File(cardPath), phone, caption)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("SEND_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Hands the personalized card + caption to WhatsApp via a standard
     * Android share-intent, pre-opening the specific guest's chat.
     * Sends from the HOST'S own installed WhatsApp account — this is
     * app-to-app sharing, not automation of WhatsApp itself.
     */
    private fun sendCardToGuestOnWhatsApp(cardFile: File, guestPhoneE164: String, caption: String) {
        val authority = "$packageName.fileprovider"
        val contentUri: Uri = FileProvider.getUriForFile(this, authority, cardFile)

        val intent = Intent(Intent.ACTION_SEND).apply {
            `package` = "com.whatsapp"
            type = "image/png"
            putExtra(Intent.EXTRA_STREAM, contentUri)
            putExtra(Intent.EXTRA_TEXT, caption)
            putExtra("jid", "$guestPhoneE164@s.whatsapp.net")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }
}
