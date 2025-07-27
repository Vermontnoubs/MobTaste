// lib/controllers/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  AppUser? _currentUser;

  // Get current user
  AppUser? get currentUser => _currentUser;

  // Initialize auth service (check if user is logged in)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      try {
        _currentUser = AppUser.fromJson(currentUserJson);
      } catch (e) {
        print('Error loading current user: $e');
        await signOut();
      }
    }
  }

  // Get current app user data
  Future<AppUser?> getCurrentAppUser() async {
    if (_currentUser == null) {
      await initialize();
    }
    return _currentUser;
  }

  // Sign up
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? restaurantName,
    String? cuisine,
    String? address,
    String? licenseNumber,
    String? vehicleType,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
        return AuthResult(success: false, error: 'All fields are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult(success: false, error: 'Invalid email format');
      }

      if (password.length < 6) {
        return AuthResult(success: false, error: 'Password must be at least 6 characters');
      }

      // Check if user already exists
      if (await _userExists(email)) {
        return AuthResult(success: false, error: 'User with this email already exists');
      }

      // Create new user
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final user = AppUser(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        restaurantName: restaurantName,
        cuisine: cuisine,
        address: address,
        licenseNumber: licenseNumber,
        vehicleType: vehicleType,
        isAvailable: role == UserRole.deliveryAgent ? true : null,
      );

      // Save user
      await _saveUser(user, password);
      _currentUser = user;
      await _saveCurrentUser(user);

      return AuthResult(success: true, user: user);
    } catch (e) {
      return AuthResult(success: false, error: 'Sign up failed: $e');
    }
  }

  // Sign in
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(success: false, error: 'Email and password are required');
      }

      // Get stored user data
      final userData = await _getUserData(email);
      if (userData == null) {
        return AuthResult(success: false, error: 'User not found');
      }

      // Verify password
      if (userData['password'] != password) {
        return AuthResult(success: false, error: 'Invalid password');
      }

      // Create user object
      final user = AppUser.fromMap(userData);
      _currentUser = user;
      await _saveCurrentUser(user);

      return AuthResult(success: true, user: user);
    } catch (e) {
      return AuthResult(success: false, error: 'Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user exists
  Future<bool> _userExists(String email) async {
    final userData = await _getUserData(email);
    return userData != null;
  }

  // Get user data by email
  Future<Map<String, dynamic>?> _getUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;
      return users[email.toLowerCase()];
    }
    return null;
  }

  // Save user data
  Future<void> _saveUser(AppUser user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    final users = usersJson != null 
        ? json.decode(usersJson) as Map<String, dynamic>
        : <String, dynamic>{};

    final userData = user.toMap();
    userData['password'] = password; // Store password (in production, this should be hashed)

    users[user.email.toLowerCase()] = userData;
    await prefs.setString(_usersKey, json.encode(users));
  }

  // Save current user
  Future<void> _saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.toJson());
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Update user profile
  Future<AuthResult> updateUserProfile(AppUser updatedUser) async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, error: 'No user logged in');
      }

      // Update in storage
      final userData = await _getUserData(_currentUser!.email);
      if (userData != null) {
        final password = userData['password'];
        await _saveUser(updatedUser, password);
        _currentUser = updatedUser;
        await _saveCurrentUser(updatedUser);
        return AuthResult(success: true, user: updatedUser);
      }

      return AuthResult(success: false, error: 'User data not found');
    } catch (e) {
      return AuthResult(success: false, error: 'Update failed: $e');
    }
  }

  // Get all users (for demo purposes)
  Future<List<AppUser>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;
      return users.values
          .map((userData) => AppUser.fromMap(userData as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Reset password (simple implementation)
  Future<AuthResult> resetPassword(String email) async {
    try {
      final userData = await _getUserData(email);
      if (userData == null) {
        return AuthResult(success: false, error: 'User not found');
      }

      // In a real app, you would send an email or SMS
      // For demo purposes, we'll just return success
      return AuthResult(success: true, error: 'Password reset instructions sent to your email');
    } catch (e) {
      return AuthResult(success: false, error: 'Reset failed: $e');
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String message;
  final AppUser? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}