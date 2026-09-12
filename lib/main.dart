import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'screens/splash/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

void main() {
  // Ensure Flutter binding is initialized for SharedPreferences and Firebase
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: Consumer<FirebaseService>(
        builder: (context, firebaseService, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: firebaseService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

