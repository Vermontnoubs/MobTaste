# Firebase Implementation for MopTaste App

## Overview

This document outlines the complete Firebase integration for the MopTaste Flutter application, implementing authentication, database management, and role-based navigation for three user types: Clients, Restaurants, and Delivery Agents.

## Firebase Services Implemented

### 1. Authentication Service (`lib/controllers/auth_service.dart`)

**Features:**
- User registration with role-based profiles
- Email/password authentication
- Password reset functionality
- Role-based data storage in Firestore
- Local data caching with SharedPreferences
- Automatic user session management

**User Roles:**
- **Client**: Can order food and browse restaurants
- **Restaurant**: Can manage menu and receive orders
- **Delivery Agent**: Can accept and deliver orders

**Key Methods:**
- `signUpWithEmailAndPassword()` - Register new users with role-specific data
- `signInWithEmailAndPassword()` - Authenticate existing users
- `signOut()` - Sign out and clear local data
- `getCurrentAppUser()` - Get current user profile from Firestore
- `updateUserProfile()` - Update user information
- `resetPassword()` - Send password reset email

### 2. Restaurant Service (`lib/controllers/restaurant_service.dart`)

**Features:**
- Restaurant profile management
- Menu item CRUD operations
- Restaurant discovery and search
- Rating system integration

**Key Methods:**
- `createRestaurantProfile()` - Create restaurant profile during signup
- `getAllRestaurants()` - Fetch all active restaurants
- `getRestaurantById()` - Get specific restaurant data
- `addMealToMenu()` - Add new menu items
- `updateMeal()` - Update existing menu items
- `deleteMeal()` - Remove menu items
- `updateRestaurantRating()` - Update restaurant ratings

### 3. Order Service (`lib/controllers/order_service.dart`)

**Features:**
- Order creation and management
- Real-time order tracking
- Status updates throughout delivery process
- Role-based order filtering
- Order statistics and analytics

**Key Methods:**
- `createOrder()` - Create new orders
- `getClientOrders()` - Get orders for specific client
- `getRestaurantOrders()` - Get orders for specific restaurant
- `getDeliveryAgentOrders()` - Get orders for specific delivery agent
- `updateOrderStatus()` - Update order status
- `assignDeliveryAgent()` - Assign delivery agent to order
- `getOrderStatistics()` - Get order analytics

## Data Models

### 1. User Model (`lib/models/user.dart`)

```dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  
  // Role-specific fields
  final String? restaurantName;    // For restaurant users
  final String? cuisine;           // For restaurant users
  final String? address;           // For restaurant and delivery agents
  final String? licenseNumber;     // For delivery agents
  final String? vehicleType;       // For delivery agents
  final bool? isAvailable;         // For delivery agents
}
```

### 2. Enhanced Models

**Meal Model**: Updated with Firebase serialization methods
**Order Model**: Enhanced with Firebase integration
**Restaurant Model**: Integrated with Firestore operations

## Authentication Flow

### Registration Process

1. **User Input**: User provides basic information and selects role
2. **Role-Specific Fields**: Additional fields based on selected role:
   - **Restaurant**: Restaurant name, cuisine type, address
   - **Delivery Agent**: License number, vehicle type, address
   - **Client**: Basic information only
3. **Firebase Auth**: Create user account with email/password
4. **Firestore Storage**: Store user profile with role-specific data
5. **Navigation**: Redirect to appropriate dashboard based on role

### Login Process

1. **Authentication**: Verify email/password with Firebase Auth
2. **Profile Retrieval**: Fetch user profile from Firestore
3. **Local Storage**: Cache user data locally
4. **Role-Based Navigation**: Redirect to appropriate dashboard

## Firestore Database Structure

```
/users/{userId}
  - uid: string
  - name: string
  - email: string
  - phone: string
  - role: string (client|restaurant|deliveryAgent)
  - createdAt: timestamp
  - restaurantName: string (optional)
  - cuisine: string (optional)
  - address: string (optional)
  - licenseNumber: string (optional)
  - vehicleType: string (optional)
  - isAvailable: boolean (optional)

/restaurants/{restaurantId}
  - id: string
  - name: string
  - cuisine: string
  - address: string
  - description: string
  - imageUrl: string
  - rating: number
  - totalRatings: number
  - isActive: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
  
  /menu/{menuItemId}
    - name: string
    - description: string
    - price: number
    - imageUrl: string
    - isMeal: boolean
    - ingredients: array
    - isAvailable: boolean
    - createdAt: timestamp
    - updatedAt: timestamp

/orders/{orderId}
  - clientId: string
  - clientName: string
  - clientAddress: string
  - items: array
  - orderDate: timestamp
  - status: string
  - deliveryAgentId: string (optional)
  - deliveryAgentName: string (optional)
  - deliveryFee: number
  - pickupLocation: string
  - orderType: string
  - restaurantId: string (optional)
  - totalAmount: number
  - createdAt: timestamp
  - updatedAt: timestamp
```

## Security Rules

Implement these Firestore security rules for proper data protection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Restaurants can manage their own data
    match /restaurants/{restaurantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == restaurantId;
      
      match /menu/{menuId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid == restaurantId;
      }
    }
    
    // Orders - clients can create, restaurants and delivery agents can update
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.clientId ||
         request.auth.uid == resource.data.restaurantId ||
         request.auth.uid == resource.data.deliveryAgentId);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.restaurantId ||
         request.auth.uid == resource.data.deliveryAgentId);
    }
  }
}
```

## Updated UI Components

### 1. Authentication Screens

**Login Screen (`lib/screens/auth/login_screen.dart`)**:
- Firebase authentication integration
- Error handling with user-friendly messages
- Password reset functionality
- Automatic role-based navigation

**Signup Screen (`lib/screens/auth/signup_screen.dart`)**:
- Role selection with dynamic form fields
- Role-specific validation
- Firebase user creation with profile data
- Comprehensive error handling

### 2. Dashboard Updates

**Client Dashboard (`lib/screens/client/client_dashboard.dart`)**:
- Real-time restaurant data from Firestore
- Firebase authentication state management
- Enhanced search and filtering
- Loading states and error handling

**Restaurant Dashboard (`lib/screens/restaurant/restaurant_dashboard.dart`)**:
- Real-time order management
- Firebase-powered menu management
- Order status updates
- Analytics integration

### 3. Navigation and State Management

**Splash Screen (`lib/screens/splash_screen.dart`)**:
- Firebase authentication state checking
- Automatic role-based navigation
- Improved loading experience

**Auth Wrapper (`lib/utils/auth_wrapper.dart`)**:
- Stream-based authentication state management
- Automatic re-authentication
- Role-based navigation logic

## Implementation Steps Completed

1. ✅ **Firebase Setup**: Added Firebase dependencies and configuration
2. ✅ **Authentication Service**: Complete user authentication system
3. ✅ **User Model**: Enhanced user model with role-based fields
4. ✅ **Restaurant Service**: Restaurant and menu management
5. ✅ **Order Service**: Order management and tracking
6. ✅ **UI Updates**: Updated all authentication and dashboard screens
7. ✅ **Navigation**: Role-based navigation system
8. ✅ **Error Handling**: Comprehensive error handling throughout

## Next Steps for Full Implementation

1. **Firebase Project Setup**: Create Firebase project and configure for your app
2. **Security Rules**: Implement the provided Firestore security rules
3. **Testing**: Test all user flows with real Firebase backend
4. **Order Flow**: Complete order placement and tracking functionality
5. **Real-time Updates**: Implement real-time order status updates
6. **Image Upload**: Add Firebase Storage for image uploads
7. **Push Notifications**: Add Firebase Cloud Messaging for order updates
8. **Analytics**: Implement Firebase Analytics for user behavior tracking

## Configuration Required

1. **Firebase Console Setup**:
   - Create new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Firebase Storage (for images)
   - Configure security rules

2. **App Configuration**:
   - Update `firebase_options.dart` with your project configuration
   - Ensure all Firebase services are properly initialized

3. **Testing**:
   - Test user registration for all roles
   - Test login/logout functionality
   - Test role-based navigation
   - Test basic CRUD operations

This implementation provides a solid foundation for a production-ready food delivery app with proper user management, real-time data synchronization, and role-based access control.