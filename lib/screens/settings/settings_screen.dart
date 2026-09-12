import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirects to Profile Screen since settings are managed inline
    return const ProfileScreen();
  }
}
