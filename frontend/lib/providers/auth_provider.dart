import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await AuthAPI.login(email, password);
      _token = response['access_token'];

      // 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      // 사용자 정보 가져오기
      _user = await AuthAPI.getCurrentUser(_token!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      try {
        _user = await AuthAPI.getCurrentUser(_token!);
        notifyListeners();
      } catch (e) {
        logout();
      }
    }
  }
}
