import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:spendsense/app/router.dart';
import 'package:spendsense/features/home_widgets/domain/home_widget_launch.dart';

class HomeWidgetLaunchListener extends ConsumerStatefulWidget {
  const HomeWidgetLaunchListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetLaunchListener> createState() =>
      _HomeWidgetLaunchListenerState();
}

class _HomeWidgetLaunchListenerState
    extends ConsumerState<HomeWidgetLaunchListener> {
  StreamSubscription<Uri?>? _subscription;

  @override
  void initState() {
    super.initState();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleLaunch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= HomeWidget.widgetClicked.listen(_handleLaunch);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleLaunch(Uri? uri) {
    if (uri == null) {
      return;
    }

    final route = HomeWidgetLaunch.routeFor(uri);
    if (route == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(routerProvider).go(route);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
