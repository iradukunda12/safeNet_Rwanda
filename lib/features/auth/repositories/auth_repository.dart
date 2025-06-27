import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseAnalytics _analytics;

  AuthRepository(this._auth, this._analytics);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp(String email, String password, String firstName, String lastName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        // ✅ Save additional user info in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ✅ Analytics: log sign-up and set user ID
        await _analytics.logSignUp(signUpMethod: 'email');
        await _analytics.setUserId(id: user.uid);
      }

      return user;
    } catch (e) {
      print('Error signing up user: $e');
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'firstName': '',
          'lastName': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Analytics: log login and set user ID
      await _analytics.logLogin(loginMethod: 'email');
      await _analytics.setUserId(id: user.uid);
    }

    return user;
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();

    // ✅ Analytics: log custom logout event
    await _analytics.logEvent(name: 'logout');
  }
}
