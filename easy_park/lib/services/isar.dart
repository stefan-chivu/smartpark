import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/models/isar_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

class IsarService {
  static late final Isar isar;
  static late IsarUser isarUser;
  static late List<IsarCar> isarCars;

  IsarService._privateConstructor();
  static final IsarService instance = IsarService._privateConstructor();

  static Future<void> openSchemas() async {
    isar = await Isar.open([IsarUserSchema, IsarCarSchema], inspector: true);
    await initUser();
    isarCars =
        await isar.isarCars.filter().ownerUidEqualTo(isarUser.uid).findAll();
  }

  static Future<void> initUser() async {
    isarUser = await isar.isarUsers.get(0) ??
        IsarUser(
            uid: '',
            email: '',
            isAdmin: false,
            firstName: '',
            lastName: '',
            homeAddress: '',
            workAddress: '',
            onboardingComplete: false);
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
          homeAddress: '',
          workAddress: '',
          onboardingComplete: false);

      isarUser = isarUserFromFirestoreUser;
      await isar.isarUsers.put(isarUser);
    });
  }

  static Future<void> setUser(IsarUser user) async {
    isarUser = user;
    await isar.writeTxn(() async {
      await isar.isarUsers.put(user);
    });
  }

  static Future<void> updateUser() async {
    await isar.writeTxn(() async {
      await isar.isarUsers.put(isarUser);
    });
  }

  static Future<void> deleteLocalUser() async {
    await isar.writeTxn(() async {
      await isar.isarCars.filter().ownerUidEqualTo(isarUser.uid).deleteAll();
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

  static Future<void> setUserCars(List<IsarCar> cars) async {
    isarCars = cars;
    await isar.writeTxn(() async {
      await isar.isarCars.putAll(cars);
    });
  }

  static Future<void> addUserCar(IsarCar car) async {
    isarCars.add(car);
    await isar.writeTxn(() async {
      await isar.isarCars.put(car);
    });
  }

  static deleteUserCar(IsarCar car) async {
    isarCars.removeWhere((element) => element.licensePlate == car.licensePlate);
    await isar.writeTxn(() async {
      await isar.isarCars
          .filter()
          .licensePlateEqualTo(car.licensePlate)
          .deleteAll();
    });
  }

  static Future<void> markOnboardingCompleted() async {
    isarUser.onboardingComplete = true;
    await updateUser();
  }
}
