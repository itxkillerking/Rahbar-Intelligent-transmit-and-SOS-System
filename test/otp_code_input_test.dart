import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rahbar/presentation/auth/components/otp_code_input.dart';

void main() {
  testWidgets('OtpCodeInput focus and interaction test', (WidgetTester tester) async {
    final controller = TextEditingController();
    String changedValue = '';
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OtpCodeInput(
              controller: controller,
              onChanged: (val) {
                changedValue = val;
              },
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.byType(TextField), findsOneWidget);
    
    // Find all box GestureDetectors (there should be 6)
    // Some widgets might inject GestureDetectors, but our AnimatedContainers are wrapped in one.
    final boxFinders = find.byType(AnimatedContainer);
    expect(boxFinders, findsNWidgets(6));
    
    // Tap the first box
    await tester.tap(boxFinders.first);
    await tester.pumpAndSettle();
    
    // Verify it has focus
    final TextField textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.focusNode?.hasFocus, true);
    
    // Enter text
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pumpAndSettle();
    
    expect(controller.text, '1234');
    expect(changedValue, '1234');
    
    // Unfocus
    textField.focusNode?.unfocus();
    await tester.pumpAndSettle();
    expect(textField.focusNode?.hasFocus, false);
    
    // Tap 3rd box (index 2)
    await tester.tap(boxFinders.at(2));
    await tester.pumpAndSettle();
    
    // Verify focus returned and selection moved
    expect(textField.focusNode?.hasFocus, true);
    expect(controller.selection.baseOffset, 2);
    
    // Tap a box outside the current length (e.g. index 5)
    await tester.tap(boxFinders.at(5));
    await tester.pumpAndSettle();
    
    // It should constrain cursor to max length (4)
    expect(controller.selection.baseOffset, 4);
  });
}
