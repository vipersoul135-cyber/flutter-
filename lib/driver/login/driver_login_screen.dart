import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';

class DriverLoginScreen extends StatelessWidget {
  const DriverLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialRoleIndex: 1);
  }
}
