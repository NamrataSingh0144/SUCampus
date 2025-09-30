import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Test Firestore connection
  Future<void> testFirestoreConnection() async {
    try {
      await _firestore.collection('test').add({
        'message': 'Firestore is working!',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print("✅ Firestore connection successful!");
    } catch (e) {
      print("❌ Firestore connection failed: $e");
    }
  }


  // SIGN UP FUNCTION
  // Update your signUp method in firebase_auth_service.dart:
  // ALTERNATIVE SIGN UP FUNCTION - bypasses UserCredential return issue
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    try {
      print("📝 Starting signup for: $email with role: ${role.name}");

      // Create user account - but don't store the UserCredential
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user immediately after creation
      User? user = _auth.currentUser;
      if (user == null) throw 'User creation failed';

      print("✅ Firebase Auth account created, UID: ${user.uid}");

      // Update display name
      await user.updateDisplayName(username);
      print("✅ Display name updated");

      // Create user document in Firestore
      await _createUserDocument(
        userId: user.uid,
        email: email,
        username: username,
        role: role,
      );

      print("✅ Firestore documents created");

      return {
        'success': true,
        'user': null, // Don't return user object to avoid serialization issues
        'role': role,
        'message': 'Account created successfully!',
      };
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      print("❌ Signup error: $e");
      return {
        'success': false,
        'message': 'Signup failed: $e',
      };
    }
  }

  // SIGN IN FUNCTION
  // ALTERNATIVE SIGN IN FUNCTION
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print("🔐 Attempting to sign in with: $email");

      // Sign in but don't store UserCredential
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get current user after sign in
      User? user = _auth.currentUser;
      if (user == null) throw 'Sign in failed';

      print("✅ Firebase Auth successful, UID: ${user.uid}");

      // Get user role from Firestore
      UserRole userRole = await getUserRole(user.uid);

      print("👤 User role found: ${userRole.name}");

      return {
        'success': true,
        'user': null, // Don't return user object
        'role': userRole,
        'message': 'Login successful!',
      };
    } on FirebaseAuthException catch (e) {
      print("❌ FirebaseAuthException: ${e.code} - ${e.message}");
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      print("💥 Unexpected error: $e");
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  // SIGN OUT FUNCTION
  Future<Map<String, dynamic>> signOut() async {
    try {
      await _auth.signOut();
      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to sign out: $e',
      };
    }
  }

  // RESET PASSWORD FUNCTION
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send reset email: $e',
      };
    }
  }

  // GET USER ROLE
  Future<UserRole> getUserRole(String userId) async {
    try {
      print("📄 Fetching user role for UID: $userId");

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      print("📄 User document exists: ${userDoc.exists}");

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print("📄 User document data: $data");

        String roleString = data['role'] as String;
        print("👤 Role string from Firestore: $roleString");

        UserRole role = UserRole.values.firstWhere((e) => e.name == roleString);
        print("👤 Converted to UserRole enum: ${role.name}");

        return role;
      } else {
        throw 'User document not found in Firestore';
      }
    } catch (e) {
      print("💥 Error fetching user role: $e");
      throw 'Failed to fetch user role: $e';
    }
  }

  // GET USER DATA
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data: $e';
    }
  }

  // UPDATE USER PROFILE
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? username,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (username != null) {
        updateData['username'] = username;
        updateData['displayName'] = username;
        // Also update Firebase Auth display name
        await _auth.currentUser?.updateDisplayName(username);
      }

      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['defaultAddress'] = address;

      updateData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _firestore.collection('users').doc(userId).update(updateData);

      return {
        'success': true,
        'message': 'Profile updated successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile: $e',
      };
    }
  }

  // EMAIL VERIFICATION FUNCTIONS
  // Add these methods to your FirebaseAuthService class

// Send email verification
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      if (user.emailVerified) {
        return {
          'success': true,
          'message': 'Email is already verified',
        };
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent! Please check your inbox.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification email: $e',
      };
    }
  }

// Check email verification status
  Future<Map<String, dynamic>> checkEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Reload user to get latest verification status
      await user.reload();
      user = _auth.currentUser; // Get updated user

      if (user?.emailVerified == true) {
        // Update Firestore to reflect verification status
        await _firestore.collection('users').doc(user!.uid).update({
          'emailVerified': true,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });

        return {
          'success': true,
          'verified': true,
          'message': 'Email verified successfully!',
        };
      } else {
        return {
          'success': true,
          'verified': false,
          'message': 'Email not yet verified',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error checking verification: $e',
      };
    }
  }

// Get current verification status
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // CHANGE PASSWORD
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password changed successfully!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password: $e',
      };
    }
  }

  // CREATE USER DOCUMENT IN FIRESTORE
  Future<void> _createUserDocument({
    required String userId,
    required String email,
    required String username,
    required UserRole role,
  }) async {
    try {
      print("📝 Creating user document for UID: $userId");

      // Create main user document with basic data
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'username': username,
        'displayName': username,
        'role': role.name,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
        'emailVerified': false,
      });

      print("✅ Main user document created");

      // Create role-specific document
      await _createRoleSpecificDocument(userId, role, username, email);

      print("✅ Role-specific document created");

    } catch (e) {
      print("❌ Error creating user document: $e");
      throw 'Failed to create user document: $e';
    }
  }

  // CREATE ROLE-SPECIFIC DOCUMENTS
  Future<void> _createRoleSpecificDocument(
      String userId,
      UserRole role,
      String username,
      String email,
      ) async {
    switch (role) {
      case UserRole.student:
      // For students (food ordering users)
        await _firestore.collection('user_profiles').doc(userId).set({
          'userId': userId,
          'phone': '',
          'defaultAddress': '',
          'totalOrders': 0,
          'favoriteShops': [],
          'orderHistory': [],
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        break;

      case UserRole.shop:
      // For shop owners
        await _firestore.collection('shops').doc(userId).set({
          'ownerId': userId,
          'shopName': '',
          'description': '',
          'category': '',
          'location': '',
          'contact': '',
          'isOpen': false,
          'isVerified': false,
          'rating': 0.0,
          'totalOrders': 0,
          'totalRatings': 0,
          'deliveryFee': 0,
          'openingHours': {
            'monday': '9:00-18:00',
            'tuesday': '9:00-18:00',
            'wednesday': '9:00-18:00',
            'thursday': '9:00-18:00',
            'friday': '9:00-18:00',
            'saturday': '9:00-17:00',
            'sunday': 'closed',
          },
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        break;

      case UserRole.admin:
      // For admins
        await _firestore.collection('admins').doc(userId).set({
          'userId': userId,
          'adminLevel': 'moderator',
          'permissions': ['verify_shops', 'manage_orders', 'handle_disputes'],
          'department': 'Campus Services',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        break;
    }
  }

  // HANDLE FIREBASE AUTH EXCEPTIONS
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }


  // UTILITY FUNCTIONS
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;

  // CHECK IF USER EXISTS
  Future<bool> doesUserExist(String email) async {
    try {
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}