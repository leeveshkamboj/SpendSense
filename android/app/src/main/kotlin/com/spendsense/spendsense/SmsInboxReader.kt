package com.spendsense.spendsense

import android.content.Context
import android.net.Uri
import android.provider.Telephony
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * Shared SMS + MMS/RCS inbox reader for the UI and background Flutter engines.
 */
object SmsInboxReader {
    private const val TAG = "SpendSense.Sms"
    private const val CHANNEL_SMS = "sms"
    private const val CHANNEL_RCS_MMS = "rcs_mms"
    private const val MMS_ADDRESS_FROM = 137
    private const val MESSAGE_BOX_DRAFT = 3

    fun readAllMessagesSince(context: Context, sinceMs: Long): List<Map<String, Any>> {
        val smsMessages = readSmsInboxSince(context, sinceMs)
        val mmsMessages = readMmsInboxSince(context, sinceMs)
        val merged = dedupeMessages(smsMessages + mmsMessages)
        Log.i(
            TAG,
            "[DEBUG-sms] inboxRead sinceMs=$sinceMs sms=${smsMessages.size} " +
                "mms=${mmsMessages.size} unique=${merged.size}",
        )
        return merged
    }

    private fun readSmsInboxSince(context: Context, sinceMs: Long): List<Map<String, Any>> {
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

        context.contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
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

    private fun readMmsInboxSince(context: Context, sinceMs: Long): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val sinceSec = sinceMs / 1000
        val uri = Telephony.Mms.CONTENT_URI
        val projection = arrayOf(
            Telephony.Mms._ID,
            Telephony.Mms.DATE,
            Telephony.Mms.MESSAGE_BOX,
        )
        val selection = "${Telephony.Mms.DATE} >= ? AND ${Telephony.Mms.MESSAGE_BOX} != ?"
        val selectionArgs = arrayOf(
            sinceSec.toString(),
            MESSAGE_BOX_DRAFT.toString(),
        )
        val sortOrder = "${Telephony.Mms.DATE} ASC"

        try {
            context.contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
                ?.use { cursor ->
                    val idIndex = cursor.getColumnIndexOrThrow(Telephony.Mms._ID)
                    val dateIndex = cursor.getColumnIndexOrThrow(Telephony.Mms.DATE)

                    while (cursor.moveToNext()) {
                        val mmsId = cursor.getLong(idIndex)
                        val body = readMmsText(context, mmsId)?.trim().orEmpty()
                        if (body.isEmpty()) continue

                        val receivedAtMs = cursor.getLong(dateIndex) * 1000
                        val sender = readMmsSender(context, mmsId)

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
        } catch (error: Exception) {
            Log.e(TAG, "[DEBUG-sms] MMS inbox read failed", error)
        }

        return messages
    }

    private fun readMmsText(context: Context, mmsId: Long): String? {
        val partUri = Uri.parse("content://mms/part")
        val partCursor = context.contentResolver.query(
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
                val partId = cursor.getString(idIndex) ?: continue

                when {
                    contentType.startsWith("text/") -> {
                        val inlineText = cursor.getString(textIndex)
                        if (!inlineText.isNullOrBlank()) {
                            builder.append(inlineText)
                        } else {
                            builder.append(readMmsPartData(context, partId))
                        }
                    }
                    contentType.contains("botmessage", ignoreCase = true) ||
                        contentType.equals("application/json", ignoreCase = true) ||
                        contentType.endsWith("+json", ignoreCase = true) -> {
                        val raw = cursor.getString(textIndex)
                            ?.takeIf { it.isNotBlank() }
                            ?: readMmsPartData(context, partId)
                        val extracted = extractBotMessageText(raw)
                        if (extracted.isNotBlank()) {
                            builder.append(extracted)
                        }
                    }
                }
            }
        }

        val text = builder.toString().trim()
        return text.ifEmpty { null }
    }

    private fun extractBotMessageText(raw: String): String {
        if (raw.isBlank()) {
            return ""
        }

        return try {
            val root = JSONObject(raw)
            val content = root
                .optJSONObject("message")
                ?.optJSONObject("generalPurposeCard")
                ?.optJSONObject("content")
                ?: root
                    .optJSONObject("message")
                    ?.optJSONObject("generalPurposeCardCarousel")
                    ?.optJSONArray("content")
                    ?.optJSONObject(0)

            if (content != null) {
                val title = content.optString("title").trim()
                val description = content.optString("description").trim()
                return listOf(title, description)
                    .filter { it.isNotEmpty() }
                    .joinToString(separator = "\n")
            }

            val flattened = StringBuilder()
            flattenJsonText(root, flattened)
            flattened.toString().trim()
        } catch (_: Exception) {
            raw
        }
    }

    private fun flattenJsonText(value: Any?, out: StringBuilder) {
        when (value) {
            is JSONObject -> {
                val keys = value.keys()
                while (keys.hasNext()) {
                    val key = keys.next()
                    if (key == "title" || key == "description" || key == "text") {
                        val text = value.optString(key).trim()
                        if (text.isNotEmpty()) {
                            if (out.isNotEmpty()) out.append('\n')
                            out.append(text)
                        }
                    } else {
                        flattenJsonText(value.opt(key), out)
                    }
                }
            }
            is JSONArray -> {
                for (i in 0 until value.length()) {
                    flattenJsonText(value.opt(i), out)
                }
            }
        }
    }

    private fun readMmsPartData(context: Context, partId: String): String {
        return try {
            context.contentResolver.openInputStream(Uri.parse("content://mms/part/$partId"))
                ?.use { stream ->
                    BufferedReader(InputStreamReader(stream)).readText()
                }
                .orEmpty()
        } catch (_: Exception) {
            ""
        }
    }

    private fun readMmsSender(context: Context, mmsId: Long): String {
        val uri = Uri.parse("content://mms/$mmsId/addr")
        val cursor = context.contentResolver.query(
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
}
