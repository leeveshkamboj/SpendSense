package com.spendsense.spendsense

import android.app.PendingIntent
import android.content.Context
import android.net.Uri
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
}
