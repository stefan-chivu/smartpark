import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges().map((User? user) => user);
  }

  // sign in with email&password
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // user will be saved in provider
      User? user = result.user;
      if (user != null) {
        bool isAdmin = false;
        try {
          isAdmin = await SqlService.getUserAdminStatus(user.uid);
        } catch (e) {
          throw FirebaseAuthException(code: 'sql-error');
        }

        await IsarService.createUserFromFirestoreUser(user, isAdmin);
        print(
            "Successfully saved user locally. UID: ${user.uid}. Admin: $isAdmin");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'An user with this e-mail/password was not found';
      } else if (e.code == 'wrong-password') {
        return 'An user with this e-mail/password was not found';
      } else if (e.code == 'sql-error') {
        return 'We had some trouble signing you in, please try again';
      }
    }
    return "success";
  }

  // register in with email&password
  Future<String> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // user will be saved in provider
      User? user = result.user;
      if (user != null) {
        await IsarService.createUserFromFirestoreUser(user, false);
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
    try {
      await IsarService.deleteLocalUser();
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
