// lib/controllers/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'restaurant_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RestaurantService _restaurantService = RestaurantService();

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

  // Robust registration method with PigeonUserDetails error handling
  Future<AuthResult> signUpRobust({
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
    // First attempt: Try the standard registration
    try {
      print('Attempting standard registration...');
      return await signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        restaurantName: restaurantName,
        cuisine: cuisine,
        address: address,
        licenseNumber: licenseNumber,
        vehicleType: vehicleType,
      );
    } catch (e) {
      print('Standard registration failed: $e');
      
      // Check if it's the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>') ||
          e.toString().contains('type cast')) {
        
        print('Detected PigeonUserDetails error, trying alternative method...');
        
        // Second attempt: Try minimal registration
        try {
          return await signUpWithEmailAndPasswordMinimal(
            email: email,
            password: password,
            name: name,
            phone: phone,
            role: role,
            restaurantName: restaurantName,
            cuisine: cuisine,
            address: address,
            licenseNumber: licenseNumber,
            vehicleType: vehicleType,
          );
        } catch (e2) {
          print('Minimal registration also failed: $e2');
          
          // Third attempt: Direct Firebase Auth with delayed Firestore creation
          try {
            return await _signUpDirect(
              email: email,
              password: password,
              name: name,
              phone: phone,
              role: role,
              restaurantName: restaurantName,
              cuisine: cuisine,
              address: address,
              licenseNumber: licenseNumber,
              vehicleType: vehicleType,
            );
          } catch (e3) {
            print('Direct registration failed: $e3');
            return AuthResult(
              success: false, 
              message: 'Registration failed due to a platform issue. Please update the app or try again later.'
            );
          }
        }
      }
      
      // Re-throw if it's not the PigeonUserDetails error
      rethrow;
    }
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
      print('Starting user registration for email: $email');
      
      // Create user account
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase user created successfully');

      final User? user = result.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to create user account');
      }

      print('User object retrieved: ${user.uid}');

      // Update display name with additional error handling
      try {
        await user.updateDisplayName(name);
        print('Display name updated successfully');
      } catch (e) {
        print('Warning: Failed to update display name: $e');
        // Continue anyway, this is not critical
      }

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

      print('Creating Firestore user document...');
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
      print('Firestore user document created successfully');

      // If restaurant user, create restaurant profile
      if (role == UserRole.restaurant && restaurantName != null && cuisine != null && address != null) {
        print('Creating restaurant profile...');
        final restaurantCreated = await _restaurantService.createRestaurantProfile(
          userId: user.uid,
          name: restaurantName,
          cuisine: cuisine,
          address: address,
          description: 'Welcome to $restaurantName! We serve delicious $cuisine cuisine.',
        );
        
        if (!restaurantCreated) {
          print('Warning: Failed to create restaurant profile for user ${user.uid}');
        } else {
          print('Restaurant profile created successfully');
        }
      }

      // Save user data locally
      print('Saving user data locally...');
      await _saveUserDataLocally(appUser);
      print('User data saved locally');

      return AuthResult(success: true, message: 'Account created successfully', user: appUser);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      print('Unexpected error during registration: $e');
      print('Stack trace: $stackTrace');
      
      // Handle the specific PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
        return AuthResult(
          success: false, 
          message: 'Registration failed due to a platform compatibility issue. Please try again or restart the app.'
        );
      }
      
      return AuthResult(success: false, message: 'An unexpected error occurred during registration. Please try again.');
    }
  }

  // Alternative sign up method with minimal Firebase Auth API calls
  Future<AuthResult> signUpWithEmailAndPasswordMinimal({
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
      print('Starting minimal user registration for email: $email');
      
      // Create user account (minimal Firebase Auth interaction)
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to create user account');
      }

      print('User created with UID: ${user.uid}');

      // Skip updateDisplayName to avoid potential Pigeon issues
      // We'll store the name in Firestore instead

      // Create user document in Firestore immediately
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

      print('Creating Firestore user document...');
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
      print('Firestore user document created successfully');

      // If restaurant user, create restaurant profile
      if (role == UserRole.restaurant && restaurantName != null && cuisine != null && address != null) {
        print('Creating restaurant profile...');
        final restaurantCreated = await _restaurantService.createRestaurantProfile(
          userId: user.uid,
          name: restaurantName,
          cuisine: cuisine,
          address: address,
          description: 'Welcome to $restaurantName! We serve delicious $cuisine cuisine.',
        );
        
        if (restaurantCreated) {
          print('Restaurant profile created successfully');
        }
      }

      // Save user data locally
      await _saveUserDataLocally(appUser);

      return AuthResult(success: true, message: 'Account created successfully', user: appUser);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e, stackTrace) {
      print('Error in minimal registration: $e');
      print('Stack trace: $stackTrace');
      return AuthResult(success: false, message: 'Registration failed. Please try again.');
    }
  }

  // Direct Firebase Auth registration with minimal platform interaction
  Future<AuthResult> _signUpDirect({
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
      print('Attempting direct Firebase Auth registration...');
      
      // Create only the Firebase Auth user, no additional calls
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to create user account');
      }

      print('Firebase Auth user created: ${user.uid}');

      // Wait a moment to ensure user is fully created
      await Future.delayed(const Duration(milliseconds: 500));

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

      print('Creating Firestore document...');
      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

      // Create restaurant profile if needed
      if (role == UserRole.restaurant && restaurantName != null && cuisine != null && address != null) {
        await _restaurantService.createRestaurantProfile(
          userId: user.uid,
          name: restaurantName,
          cuisine: cuisine,
          address: address,
          description: 'Welcome to $restaurantName! We serve delicious $cuisine cuisine.',
        );
      }

      // Save locally
      await _saveUserDataLocally(appUser);

      return AuthResult(success: true, message: 'Account created successfully', user: appUser);
    } catch (e) {
      print('Direct registration error: $e');
      return AuthResult(success: false, message: 'Registration failed: ${e.toString()}');
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