import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialRoleIndex: 2);
  }
}
