// This is a basic Flutter widget test for Campus Bus Live.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_bus_live/main.dart';
import 'package:campus_bus_live/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Mock initial SharedPreferences values for the test environment
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the SplashScreen is built.
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}

