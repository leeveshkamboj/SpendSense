import 'package:flutter/services.dart';

const quickAddChannelName = 'com.spendsense.spendsense/quick_add';

Future<String> readQuickAddInitialKind() async {
  const channel = MethodChannel(quickAddChannelName);
  try {
    final kind = await channel.invokeMethod<String>('getInitialKind');
    return kind ?? 'expense';
  } on MissingPluginException {
    return 'expense';
  }
}

Future<void> finishQuickAddActivity() async {
  const channel = MethodChannel(quickAddChannelName);
  try {
    await channel.invokeMethod<void>('finish');
  } on MissingPluginException {
    // Tests / non-Android hosts.
  }
}
