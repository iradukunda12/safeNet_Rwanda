import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_project/features/auth/controllers/auth_controller.dart';

class AuthNotifier extends ChangeNotifier {
  final Ref ref;
  User? _user;

  AuthNotifier(this.ref) {
    // Listen to auth state changes
    ref.read(authRepositoryProvider).authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isSignedIn => _user != null;
}

// Provider for AuthNotifier
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(ref);
});
