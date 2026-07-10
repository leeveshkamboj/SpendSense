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

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    expect(completed, '1234');
  });
}
