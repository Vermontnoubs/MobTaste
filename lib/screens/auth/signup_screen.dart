// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../controllers/auth_service.dart';
import '../../models/user.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _authService = AuthService();
  
  String _selectedRole = 'client';
  bool _isLoading = false;

  _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserRole role;
        switch (_selectedRole) {
          case 'restaurant':
            role = UserRole.restaurant;
            break;
          case 'delivery_agent':
            role = UserRole.deliveryAgent;
            break;
          default:
            role = UserRole.client;
        }

        // Use the robust registration method that handles PigeonUserDetails errors
        final result = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: role,
          restaurantName: role == UserRole.restaurant ? _restaurantNameController.text.trim() : null,
          cuisine: role == UserRole.restaurant ? _cuisineController.text.trim() : null,
          address: (role == UserRole.restaurant || role == UserRole.deliveryAgent) ? _addressController.text.trim() : null,
          licenseNumber: role == UserRole.deliveryAgent ? _licenseNumberController.text.trim() : null,
          vehicleType: role == UserRole.deliveryAgent ? _vehicleTypeController.text.trim() : null,
        );

        setState(() => _isLoading = false);

        if (result.success && result.user != null) {
          // Navigate based on user role
          switch (result.user!.role) {
            case UserRole.client:
              Navigator.pushReplacementNamed(context, '/client-dashboard');
              break;
            case UserRole.restaurant:
              Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
              break;
            case UserRole.deliveryAgent:
              Navigator.pushReplacementNamed(context, '/delivery-agent-dashboard');
              break;
          }
        } else {
          _showErrorDialog(result.error ?? 'Signup failed');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        print('Signup error: $e');
        
        // Show a user-friendly error message
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
          _showErrorDialog('Registration failed due to a compatibility issue. Please restart the app and try again.');
        } else {
          _showErrorDialog('An unexpected error occurred. Please try again.');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificFields() {
    switch (_selectedRole) {
      case 'restaurant':
        return Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: _restaurantNameController,
              decoration: InputDecoration(
                labelText: 'Restaurant Name',
                prefixIcon: Icon(Icons.restaurant, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your restaurant name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _cuisineController,
              decoration: InputDecoration(
                labelText: 'Cuisine Type',
                prefixIcon: Icon(Icons.local_dining, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your cuisine type';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Restaurant Address',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your restaurant address';
                }
                return null;
              },
            ),
          ],
        );
      case 'delivery_agent':
        return Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: _licenseNumberController,
              decoration: InputDecoration(
                labelText: 'License Number',
                prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your license number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: Icon(Icons.motorcycle, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your vehicle type';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up for MopTaste'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center( // Center the content
            child: SingleChildScrollView( // Make it scrollable for smaller screens
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryOrange),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Join MopTaste today!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkGrey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: AppTheme.primaryOrange),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: AppTheme.primaryOrange),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: AppTheme.primaryOrange),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone, color: AppTheme.primaryOrange),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Your Role:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.neutralBlack),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.only(top: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('Client (Order food/ingredients)'),
                            value: 'client',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                          RadioListTile<String>(
                            title: Text('Delivery Agent (Deliver orders)'),
                            value: 'delivery_agent',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                          RadioListTile<String>(
                            title: Text('Restaurant (Sell food/recipes)'),
                            value: 'restaurant',
                            groupValue: _selectedRole,
                            onChanged: (value) => setState(() => _selectedRole = value!),
                            activeColor: AppTheme.primaryOrange,
                          ),
                        ],
                      ),
                    ),
                    _buildRoleSpecificFields(),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? CircularProgressIndicator(color: AppTheme.neutralWhite)
                          : Text('Create Account'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Go back to login
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(color: AppTheme.accentRed),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}