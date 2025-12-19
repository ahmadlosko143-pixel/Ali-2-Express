import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Provider for managing user profile
class UserProvider with ChangeNotifier {
  User _user = User.defaultUser();

  User get user => _user;

  /// Load user from SharedPreferences
  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');

      if (userData != null) {
        final jsonData = json.decode(userData);
        _user = User.fromJson(jsonData);
      } else {
        // Use default user if no saved data
        _user = User.defaultUser();
        await _saveUser();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
      _user = User.defaultUser();
    }
  }

  /// Save user to SharedPreferences
  Future<void> _saveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(_user.toJson());
      await prefs.setString('user', jsonData);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  /// Update user profile
  Future<void> updateUser({
    String? name,
    String? registrationNumber,
    String? profileImagePath,
  }) async {
    _user = _user.copyWith(
      name: name,
      registrationNumber: registrationNumber,
      profileImagePath: profileImagePath,
    );
    await _saveUser();
    notifyListeners();
  }

  /// Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    _user = _user.copyWith(profileImagePath: imagePath);
    await _saveUser();
    notifyListeners();
  }
}
