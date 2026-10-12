import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/core/widgets/app_button.dart';
import 'package:pet_care/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppButton renders text and triggers callback', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: 'Send OTP',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Send OTP'), findsOneWidget);
    await tester.tap(find.text('Send OTP'));
    expect(tapped, isTrue);
  });

  testWidgets('AppTextField renders label and hint', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(
            labelText: 'Mobile Number',
            hintText: 'Enter 10-digit number',
            isPhone: true,
          ),
        ),
      ),
    );

    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
  });
}
