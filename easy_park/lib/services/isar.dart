import 'package:easy_park/models/isar_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

class IsarService {
  static late final Isar isar;
  static late IsarUser isarUser;

  IsarService._privateConstructor();
  static final IsarService instance = IsarService._privateConstructor();

  static Future<void> openSchemas() async {
    isar = await Isar.open([IsarUserSchema], inspector: true);
    await initUser();
  }

  static Future<void> initUser() async {
    isarUser = await isar.isarUsers.get(0) ??
        IsarUser(
            uid: '',
            email: '',
            isAdmin: false,
            firstName: '',
            lastName: '',
            licensePlate: '',
            homeAddress: '',
            workAddress: '');
    await isar.writeTxn(() async {
      await isar.isarUsers.put(isarUser);
    });
  }

  static Future<void> createUserFromFirestoreUser(
      User user, bool isAdmin) async {
    await isar.writeTxn(() async {
      await isar.isarUsers.delete(isarUser.id);
      IsarUser isarUserFromFirestoreUser = IsarUser(
          uid: user.uid,
          email: user.email ?? "",
          isAdmin: isAdmin,
          firstName: '',
          lastName: '',
          licensePlate: '',
          homeAddress: '',
          workAddress: '');

      isarUser = isarUserFromFirestoreUser;
      await isar.isarUsers.put(isarUser);
    });
  }

  static Future<void> setUser(IsarUser user) async {
    await isar.writeTxn(() async {
      await isar.isarUsers.put(user);
    });
  }

  static Future<void> deleteLocalUser() async {
    await isar.writeTxn(() async {
      await isar.isarUsers.delete(isarUser.id);
    });
    await initUser();
  }

  static String getUid() {
    return isarUser.uid;
  }

  static bool getAdminStatus() {
    return isarUser.isAdmin;
  }
}
