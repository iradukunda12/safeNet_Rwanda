import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/repositories/auth_repository.dart';

// Firebase Auth
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// Firebase Analytics
final firebaseAnalyticsProvider = Provider((ref) => FirebaseAnalytics.instance);

// Auth Repository with analytics
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  final analytics = ref.read(firebaseAnalyticsProvider);
  return AuthRepository(auth, analytics);
});

// Current user
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseAuthProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.read(firebaseAuthProvider).currentUser;
});
