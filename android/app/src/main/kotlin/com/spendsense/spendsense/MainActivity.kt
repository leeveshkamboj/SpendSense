package com.spendsense.spendsense

import android.net.Uri
import android.provider.Telephony
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readInboxSince" -> {
                        val sinceMs = call.argument<Number>("sinceMs")?.toLong()
                        if (sinceMs == null) {
                            result.error("invalid_args", "sinceMs is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val messages = readAllMessagesSince(sinceMs)
                            Log.i(
                                TAG,
                                "readInboxSince returned ${messages.size} messages " +
                                    "(sms=${messages.count { it["channel"] == CHANNEL_SMS }}, " +
                                    "rcs_mms=${messages.count { it["channel"] == CHANNEL_RCS_MMS }})",
                            )
                            result.success(messages)
                        } catch (error: SecurityException) {
                            Log.e(TAG, "readInboxSince permission denied", error)
                            result.error("permission_denied", error.message, null)
                        } catch (error: Exception) {
                            Log.e(TAG, "readInboxSince failed", error)
                            result.error("read_failed", error.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun readAllMessagesSince(sinceMs: Long): List<Map<String, Any>> {
        Log.i(TAG, "Querying SMS and RCS/MMS inbox since $sinceMs")
        val smsMessages = readSmsInboxSince(sinceMs)
        val mmsMessages = readMmsInboxSince(sinceMs)
        return dedupeMessages(smsMessages + mmsMessages)
    }

    private fun readSmsInboxSince(sinceMs: Long): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf(
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
        )
        val selection = "${Telephony.Sms.DATE} >= ?"
        val selectionArgs = arrayOf(sinceMs.toString())
        val sortOrder = "${Telephony.Sms.DATE} ASC"

        contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
            ?.use { cursor ->
                val addressIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
                val bodyIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)
                val dateIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)

                while (cursor.moveToNext()) {
                    val sender = cursor.getString(addressIndex) ?: continue
                    val body = cursor.getString(bodyIndex)?.trim().orEmpty()
                    if (body.isEmpty()) continue
                    val receivedAtMs = cursor.getLong(dateIndex)

                    messages.add(
                        mapOf(
                            "sender" to sender,
                            "body" to body,
                            "receivedAtMs" to receivedAtMs,
                            "channel" to CHANNEL_SMS,
                        ),
                    )
                }
            }

        return messages
    }

    /**
     * Google Messages stores many RCS chats in the MMS content provider.
     * There is no public RCS-only API for third-party apps.
     */
    private fun readMmsInboxSince(sinceMs: Long): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val sinceSec = sinceMs / 1000
        val uri = Telephony.Mms.CONTENT_URI
        val projection = arrayOf(
            Telephony.Mms._ID,
            Telephony.Mms.DATE,
        )
        val selection = "${Telephony.Mms.MESSAGE_BOX} = ? AND ${Telephony.Mms.DATE} >= ?"
        val selectionArgs = arrayOf(
            Telephony.Mms.MESSAGE_BOX_INBOX.toString(),
            sinceSec.toString(),
        )
        val sortOrder = "${Telephony.Mms.DATE} ASC"

        contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
            ?.use { cursor ->
                val idIndex = cursor.getColumnIndexOrThrow(Telephony.Mms._ID)
                val dateIndex = cursor.getColumnIndexOrThrow(Telephony.Mms.DATE)

                while (cursor.moveToNext()) {
                    val mmsId = cursor.getLong(idIndex)
                    val body = readMmsText(mmsId)?.trim().orEmpty()
                    if (body.isEmpty()) continue

                    val receivedAtMs = cursor.getLong(dateIndex) * 1000
                    val sender = readMmsSender(mmsId)

                    messages.add(
                        mapOf(
                            "sender" to sender,
                            "body" to body,
                            "receivedAtMs" to receivedAtMs,
                            "channel" to CHANNEL_RCS_MMS,
                        ),
                    )
                }
            }

        return messages
    }

    private fun readMmsText(mmsId: Long): String? {
        val partUri = Uri.parse("content://mms/part")
        val partCursor = contentResolver.query(
            partUri,
            arrayOf("_id", "ct", "text"),
            "mid = ?",
            arrayOf(mmsId.toString()),
            null,
        ) ?: return null

        val builder = StringBuilder()
        partCursor.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow("_id")
            val typeIndex = cursor.getColumnIndexOrThrow("ct")
            val textIndex = cursor.getColumnIndexOrThrow("text")

            while (cursor.moveToNext()) {
                val contentType = cursor.getString(typeIndex) ?: continue
                if (!contentType.startsWith("text/")) continue

                val inlineText = cursor.getString(textIndex)
                if (!inlineText.isNullOrBlank()) {
                    builder.append(inlineText)
                    continue
                }

                val partId = cursor.getString(idIndex) ?: continue
                builder.append(readMmsPartData(partId))
            }
        }

        val text = builder.toString().trim()
        return text.ifEmpty { null }
    }

    private fun readMmsPartData(partId: String): String {
        return try {
            contentResolver.openInputStream(Uri.parse("content://mms/part/$partId"))
                ?.use { stream ->
                    BufferedReader(InputStreamReader(stream)).readText()
                }
                .orEmpty()
        } catch (error: Exception) {
            Log.w(TAG, "Failed to read MMS part $partId", error)
            ""
        }
    }

    private fun readMmsSender(mmsId: Long): String {
        val uri = Uri.parse("content://mms/$mmsId/addr")
        val cursor = contentResolver.query(
            uri,
            arrayOf("address", "type"),
            null,
            null,
            null,
        ) ?: return "unknown"

        cursor.use {
            val addressIndex = it.getColumnIndexOrThrow("address")
            val typeIndex = it.getColumnIndexOrThrow("type")
            var fallback = "unknown"

            while (it.moveToNext()) {
                val address = it.getString(addressIndex) ?: continue
                val type = it.getInt(typeIndex)
                if (type == MMS_ADDRESS_FROM) {
                    return address
                }
                if (fallback == "unknown") {
                    fallback = address
                }
            }

            return fallback
        }
    }

    private fun dedupeMessages(
        messages: List<Map<String, Any>>,
    ): List<Map<String, Any>> {
        val seen = linkedSetOf<String>()
        val unique = mutableListOf<Map<String, Any>>()

        for (message in messages) {
            val body = message["body"] as String
            val receivedAtMs = message["receivedAtMs"] as Long
            val minuteBucket = receivedAtMs / 60_000
            val normalizedBody = body.replace(Regex("\\s+"), " ").trim()
            val key = "$minuteBucket|$normalizedBody"
            if (seen.add(key)) {
                unique.add(message)
            }
        }

        return unique
    }

    companion object {
        private const val CHANNEL = "com.spendsense.spendsense/sms_inbox"
        private const val TAG = "SpendSense.SmsImport"
        private const val CHANNEL_SMS = "sms"
        private const val CHANNEL_RCS_MMS = "rcs_mms"
        private const val MMS_ADDRESS_FROM = 137
    }
}
