package com.spendsense.spendsense

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

object WidgetLaunchUtils {
    fun activityPendingIntent(context: Context, uri: String): PendingIntent =
        HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(uri),
        )

    fun bindLaunch(context: Context, views: RemoteViews, viewId: Int, uri: String) {
        views.setOnClickPendingIntent(viewId, activityPendingIntent(context, uri))
    }

    fun bindBroadcast(
        context: Context,
        views: RemoteViews,
        viewId: Int,
        action: String,
        requestCode: Int,
    ) {
        val intent = Intent(context, WidgetSmsSyncReceiver::class.java).setAction(action)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            }
        views.setOnClickPendingIntent(
            viewId,
            PendingIntent.getBroadcast(context, requestCode, intent, flags),
        )
    }
}
