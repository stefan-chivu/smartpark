import 'package:easy_park/models/isar_user.dart';
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
      // user will be stored locally
      User? user = result.user;
      if (user != null && user.email != null) {
        IsarUser? isarUser = await SqlService.getUser(user.uid, user.email!);
        if (isarUser == null) {
          throw FirebaseAuthException(code: 'sql-error');
        }
        await IsarService.setUser(isarUser);
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
      if (user != null && user.email != null) {
        try {
          await SqlService.addUserToDatabase(
              user.uid, user.email!, false, '', '', '', '', '');
        } catch (e) {
          await user.delete();
          return 'Registration failed';
        }
        await IsarService.createUserFromFirestoreUser(user, false);
        return "success";
      } else {
        return 'Registration failed';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Weak password';
      } else if (e.code == 'email-already-in-use') {
        return 'This e-mail is already in use!';
      }
    } catch (e) {
      return e.toString();
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
