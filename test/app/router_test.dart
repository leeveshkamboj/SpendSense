import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/app/router.dart';

void main() {
  testWidgets('root path redirects to dashboard without error page', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final path = state.uri.path;
        if (path.isEmpty || path == '/') {
          return dashboardLocation;
        }
        return null;
      },
      errorBuilder: (context, state) => const Scaffold(
        body: Center(child: Text('SHOULD_NOT_SEE_ERROR')),
      ),
      routes: [
        GoRoute(
          path: dashboardLocation,
          builder: (context, state) => const Scaffold(
            body: Text('Dashboard'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.text('SHOULD_NOT_SEE_ERROR'), findsNothing);
    expect(find.textContaining('GoException'), findsNothing);
    expect(find.textContaining('Page Not Found'), findsNothing);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(router.state.uri.path, dashboardLocation);
  });

  testWidgets('unknown route shows spinner then goes to dashboard', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/missing-route',
      errorBuilder: (context, state) => const _TestUnknownRouteScreen(),
      routes: [
        GoRoute(
          path: dashboardLocation,
          builder: (context, state) => const Scaffold(
            body: Text('Dashboard'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.textContaining('GoException'), findsNothing);
    expect(router.state.uri.path, dashboardLocation);
  });
}

class _TestUnknownRouteScreen extends StatefulWidget {
  const _TestUnknownRouteScreen();

  @override
  State<_TestUnknownRouteScreen> createState() =>
      _TestUnknownRouteScreenState();
}

class _TestUnknownRouteScreenState extends State<_TestUnknownRouteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.go(dashboardLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
