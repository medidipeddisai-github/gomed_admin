import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LogoutNotifier extends StateNotifier<void> {
  LogoutNotifier() : super(null);

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    // Navigate to the LoginScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}

final logoutProvider = StateNotifierProvider<LogoutNotifier, void>(
  (ref) => LogoutNotifier(),
);