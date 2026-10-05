import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/presentation/auth/login_screen.dart';
import 'package:rahbar/application/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Urdu toggle tap changes state and applies RTL', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initial state: LTR, English selected
    final directionality = tester.widget<Directionality>(
        find.descendant(of: find.byType(LoginScreen), matching: find.byType(Directionality)).first
    );
    expect(directionality.textDirection, TextDirection.ltr);

    // Verify Urdu text pill is present
    final urduTextFinder = find.text('اردو');
    expect(urduTextFinder, findsOneWidget);

    // Tap the Urdu option
    await tester.tap(urduTextFinder);
    await tester.pumpAndSettle(); // Wait for state change and animation

    // Verify state change: Directionality should now be RTL
    final newDirectionality = tester.widget<Directionality>(
        find.descendant(of: find.byType(LoginScreen), matching: find.byType(Directionality)).first
    );
    expect(newDirectionality.textDirection, TextDirection.rtl);

    // Prove selection animation changes
    // InkWell / GestureDetector intercept tap and state changes.
  });
}
