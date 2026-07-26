import 'package:flutter_test/flutter_test.dart';
import 'package:blushy_life_app/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Blushy OS Bootstrap Smoke Test', (WidgetTester tester) async {
    // Build the Blushy OS App and trigger a frame.
    await tester.pumpWidget(const BlushyApp());

    // Verify that the welcome greeting exists.
    expect(find.text('Welcome to Blushy'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // Tap on Google login to authenticate
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the app transitions to the onboarding wizard privacy screen
    expect(find.text('Your Blushy, your control'), findsOneWidget);
  });
}


