import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../driver/dashboard/driver_dashboard_screen.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _busController;
  late Animation<double> _busPosition;

  @override
  void initState() {
    super.initState();
    _busController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _busPosition = Tween<double>(begin: -100.0, end: 320.0).animate(
      CurvedAnimation(parent: _busController, curve: Curves.easeInOutCubic),
    );

    _busController.forward();

    // Set routing timer
    Timer(const Duration(milliseconds: 3200), _checkAuthAndNavigate);
  }

  @override
  void dispose() {
    _busController.dispose();
    super.dispose();
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    Widget nextScreen;
    if (firebaseService.currentStudent != null) {
      nextScreen = const HomeScreen();
    } else if (firebaseService.currentDriverBusId != null) {
      nextScreen = const DriverDashboardScreen();
    } else if (firebaseService.isAdmin) {
      nextScreen = const AdminDashboardScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.colorfulGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 50),

              // Title Branding
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),

              // Animated Bus track
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Moving Bus Icon
                    AnimatedBuilder(
                      animation: _busPosition,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_busPosition.value - 110, 0),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    // Road Line
                    Container(
                      height: 3,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),

              // College Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      'WELCOME TO',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppConstants.collegeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
