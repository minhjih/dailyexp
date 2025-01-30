import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/auth_api.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;

  User? get user => _user;
  bool get isLoading => _isLoading;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;

  Future<void> fetchUserProfile() async {
    if (_user != null) return; // 이미 데이터가 있으면 다시 요청하지 않음

    try {
      _isLoading = true;
      notifyListeners();

      final response = await AuthAPI().getUserProfile();
      _user = User.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchProfileStats() async {
    try {
      final response = await AuthAPI().getProfileStats();
      _followersCount = response['followers_count'];
      _followingCount = response['following_count'];
      notifyListeners();
    } catch (e) {
      print('Failed to fetch profile stats: $e');
    }
  }

  Future<User> loadUserProfile(int userId) async {
    try {
      final response = await AuthAPI().getUserProfileById(userId);
      return User.fromJson(response);
    } catch (e) {
      print('Failed to load user profile: $e');
      rethrow;
    }
  }

  Future<void> loadProfileStats() async {
    try {
      final stats = await AuthAPI().getProfileStats();
      _followersCount = stats['followers_count'];
      _followingCount = stats['following_count'];
      notifyListeners();
    } catch (e) {
      print('Failed to load profile stats: $e');
      rethrow;
    }
  }
}
