// lib/controllers/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current app user data
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromSnapshot(doc);
      }
    } catch (e) {
      print('Error getting current app user: $e');
    }
    return null;
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
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
      // Create user account
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to create user account');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      final appUser = AppUser(
        uid: user.uid,
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

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

      // Save user data locally
      await _saveUserDataLocally(appUser);

      return AuthResult(success: true, message: 'Account created successfully', user: appUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to sign in');
      }

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return AuthResult(success: false, message: 'User data not found');
      }

      final appUser = AppUser.fromSnapshot(doc);
      
      // Save user data locally
      await _saveUserDataLocally(appUser);

      return AuthResult(success: true, message: 'Signed in successfully', user: appUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserDataLocally();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Update user profile
  Future<AuthResult> updateUserProfile({
    String? name,
    String? phone,
    String? restaurantName,
    String? cuisine,
    String? address,
    String? licenseNumber,
    String? vehicleType,
    bool? isAvailable,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult(success: false, message: 'No user signed in');
      }

      // Get current user data
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return AuthResult(success: false, message: 'User data not found');
      }

      final currentAppUser = AppUser.fromSnapshot(doc);
      
      // Create updated user data
      final updatedUser = currentAppUser.copyWith(
        name: name,
        phone: phone,
        restaurantName: restaurantName,
        cuisine: cuisine,
        address: address,
        licenseNumber: licenseNumber,
        vehicleType: vehicleType,
        isAvailable: isAvailable,
      );

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update(updatedUser.toMap());

      // Update display name if changed
      if (name != null && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      // Save updated data locally
      await _saveUserDataLocally(updatedUser);

      return AuthResult(success: true, message: 'Profile updated successfully', user: updatedUser);
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to update profile: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to send password reset email: $e');
    }
  }

  // Get users by role (for admin purposes or delivery agent assignment)
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.toString().split('.').last)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => AppUser.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Get available delivery agents
  Future<List<AppUser>> getAvailableDeliveryAgents() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'deliveryAgent')
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => AppUser.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error getting available delivery agents: $e');
      return [];
    }
  }

  // Save user data locally
  Future<void> _saveUserDataLocally(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('userName', user.name);
    await prefs.setString('userRole', user.role.toString().split('.').last);
    await prefs.setString('userPhone', user.phone);
    await prefs.setString('userId', user.uid);
    if (user.restaurantName != null) {
      await prefs.setString('restaurantName', user.restaurantName!);
    }
    if (user.address != null) {
      await prefs.setString('userAddress', user.address!);
    }
  }

  // Clear user data locally
  Future<void> _clearUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get auth error message
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
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