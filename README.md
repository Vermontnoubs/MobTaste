# MopTaste - Local Frontend Only

A Flutter food delivery app that has been converted from Firebase to a local-only frontend application using SharedPreferences for data storage.

## Changes Made

### Firebase Removal
- ❌ Removed all Firebase dependencies from `pubspec.yaml`
- ❌ Deleted `firebase_options.dart` and `firebase.json`
- ❌ Removed Firebase initialization from `main.dart`
- ❌ Removed Firebase configuration from Android build files
- ❌ Deleted Google Services configuration files

### Local Storage Implementation
- ✅ Replaced Firebase Auth with local SharedPreferences-based authentication
- ✅ Replaced Firestore with local JSON storage using SharedPreferences
- ✅ Updated all service classes to work with local storage
- ✅ Added sample data initialization for restaurants and meals
- ✅ Maintained the same app structure and navigation flow

## Features

### Authentication
- Local user registration and login
- Role-based authentication (Client, Restaurant, Delivery Agent)
- Profile management with local storage
- Session persistence across app restarts

### Data Storage
- All user data stored locally using SharedPreferences
- Restaurant and meal data with sample content
- Order management with local persistence
- No external dependencies or internet connection required

## How to Run

1. Make sure you have Flutter installed
2. Navigate to the project directory
3. Get dependencies: `flutter pub get`
4. Run the app: `flutter run`

## App Structure

### User Roles
- **Client**: Browse restaurants, view menus, place orders
- **Restaurant**: Manage menu items, view orders, update order status  
- **Delivery Agent**: Accept delivery jobs, manage deliveries

### Local Data
- Users are stored with email as the key
- Restaurants and meals are pre-populated with sample data
- Orders are tracked with full lifecycle management
- All data persists locally between app sessions

## Development Notes

- The app maintains the same UI/UX as the original Firebase version
- All authentication flows work identically but use local storage
- Sample restaurants and meals are automatically created on first run
- User data is stored securely using SharedPreferences
- No internet connection required for any functionality

## Password Storage

⚠️ **Note**: In this demo implementation, passwords are stored in plain text locally. In a production app, passwords should be properly hashed using a secure hashing algorithm.

## Sample Data

The app includes sample restaurants:
- Buea Grill House (Cameroonian cuisine)
- Pizza Palace (Italian cuisine)  
- Spice Garden (Indian cuisine)

Each restaurant has sample meals with prices and descriptions.
