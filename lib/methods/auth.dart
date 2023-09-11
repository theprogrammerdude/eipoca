import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> createAccountWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendVerificationMail() async {
    return await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> signout() async {
    return await _auth.signOut();
  }

  Future<void> updatePassword(String password) {
    User user = _auth.currentUser!;
    return user.updatePassword(password);
  }

  Future<void> deleteAccount() {
    return _auth.currentUser!.delete();
  }
}
