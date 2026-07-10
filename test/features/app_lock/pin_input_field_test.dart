import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/app_lock/presentation/pin_input_field.dart';

void main() {
  testWidgets('PinInputField calls onCompleted after four digits', (tester) async {
    final controller = TextEditingController();
    String? completed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinInputField(
            controller: controller,
            onCompleted: (pin) => completed = pin,
          ),
        ),
      ),
    );

    for (final digit in '1234'.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }

    expect(completed, '1234');
  });

  testWidgets('PinInputField backspace removes last digit', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinInputField(controller: controller),
        ),
      ),
    );

    await tester.tap(find.text('1').last);
    await tester.tap(find.text('2').last);
    await tester.pump();

    expect(controller.text, '12');

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(controller.text, '1');
  });

  testWidgets('PinInputField shows biometric key when onBiometric is set', (
    tester,
  ) async {
    final controller = TextEditingController();
    var biometricTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinInputField(
            controller: controller,
            style: PinInputStyle.unlock,
            onBiometric: () => biometricTaps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.fingerprint));
    await tester.pump();

    expect(biometricTaps, 1);
  });
}
