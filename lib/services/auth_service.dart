// import firebase auth
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // create instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // return user credential
      return userCredential;
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }

  // sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      // sign up with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      userCredential.user!.sendEmailVerification();
      firstName = firstName[0].toUpperCase() + firstName.substring(1);
      lastName = lastName[0].toUpperCase() + lastName.substring(1);
      userCredential.user!.updateDisplayName('$firstName $lastName');
      // return user credential
      return userCredential;
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      // sign out
      await _auth.signOut();
    } catch (e) {
      // print error
      print(e);
    }
  }

  // stream of user changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // method to stream if the user email is verified
  Stream<bool> get emailVerified => _auth.authStateChanges().map(
        (user) {
          if (user != null) {
            return user.emailVerified;
          } else {
            return false;
          }
        },
      );

  // method to send email verification
  Future<void> sendEmailVerification() async {
    try {
      // get current user
      User? user = _auth.currentUser;
      // send email verification
      await user!.sendEmailVerification();
    } catch (e) {
      // print error
      print(e);
    }
  }

  // method to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // send password reset email
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // print error
      print(e);
    }
  }
}
