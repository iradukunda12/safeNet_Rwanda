import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../repositories/auth_repository.dart';

// Provide FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provide FirebaseAnalytics
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

// Provide AuthRepository with both FirebaseAuth and FirebaseAnalytics
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final analytics = ref.read(firebaseAnalyticsProvider);
  return AuthRepository(auth, analytics);
});

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.getCurrentUser();
});
