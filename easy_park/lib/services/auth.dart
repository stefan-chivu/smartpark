import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges().map((User? user) => user);
  }

  // sign in with email&password
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // user will be saved in provider
      User? user = result.user;
      if (user != null) {
        prefs.setString('uid', user.uid);
        print("Successfully saved uid locally: ${user.uid}");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'An user with this e-mail/password was not found';
      } else if (e.code == 'wrong-password') {
        return 'An user with this e-mail/password was not found';
      }
    }
    return "success";
  }

  // register in with email&password
  Future<String> registerWithEmailAndPassword(
      String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // user will be saved in provider
      User? user = result.user;
      if (user != null) {
        prefs.setString('uid', user.uid);
        print("Successfully saved uid locally: ${user.uid}");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Weak password';
      } else if (e.code == 'email-already-in-use') {
        return 'This e-mail is already in use!';
      }
    }
    return "success";
  }

  // sign-out
  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      prefs.setString('uid', '');
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
