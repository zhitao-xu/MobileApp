import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("Sign in failed: ${e.toString()}");
      }
      return Future.error(e); // Return an error if sign in fails
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("Registration failed: ${e.toString()}");
      }
      return Future.error(e); // Return an error if registration fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("Password reset failed: ${e.toString()}");
      }
    }
  }

  // Update username
  Future<void> updateUsername({
    required String username,
  }) async {
    try {
      await currentUser?.updateDisplayName(username);
      // Reload the user to get the updated information
      await currentUser?.reload();
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("Username update failed: ${e.toString()}");
      }
    }
  }

  // Delete user
  Future<void> deleteUser({
    required String mail,
    required String password,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: mail, password: password);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
      await signOut();
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("User deletion failed: ${e.toString()}");
      }
    }
  }

  // Reset user password
  Future<void> resetUserPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      if(kDebugMode) {
        // Print the error message in debug mode
        print("Password reset failed: ${e.toString()}");  
      }
    }
  }





}