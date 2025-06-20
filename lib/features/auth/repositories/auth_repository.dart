import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

Future<User?> signIn(String email, String password) async {
  final credential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user;
}

  Future<void> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}
