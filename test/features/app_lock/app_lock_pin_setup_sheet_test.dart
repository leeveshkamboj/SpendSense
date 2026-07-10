import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/app_lock/presentation/app_lock_pin_setup_sheet.dart';
import 'package:spendsense/features/app_lock/presentation/pin_input_field.dart';

void main() {
  testWidgets('confirm PIN step accepts keypad input after enter step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showAppLockPinSetupSheet(
                  context: context,
                  title: 'Set app lock PIN',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.text('Confirm PIN'), findsOneWidget);

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // Sheet should close after matching confirm PIN.
    expect(find.text('Confirm PIN'), findsNothing);
  });

  testWidgets('PinInputField follows a swapped controller', (tester) async {
    final first = TextEditingController();
    final second = TextEditingController();
    var useFirst = true;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  PinInputField(
                    controller: useFirst ? first : second,
                    onCompleted: (_) {},
                  ),
                  TextButton(
                    onPressed: () => setState(() => useFirst = false),
                    child: const Text('Swap'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('1').last);
    await tester.pump();
    expect(first.text, '1');

    await tester.tap(find.text('Swap'));
    await tester.pump();

    await tester.tap(find.text('2').last);
    await tester.pump();

    expect(first.text, '1');
    expect(second.text, '2');
  });
}
