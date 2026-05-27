import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<UserProfile?> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.login(email, password);

      if (profile == null) {
        errorMessage = 'Login failed or user profile not found';
      }

      return profile;
    } catch (e) {
      errorMessage = 'Login Failed';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}