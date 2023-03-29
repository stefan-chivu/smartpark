import 'package:isar/isar.dart';

part 'isar_user.g.dart';

@collection
class IsarUser {
  final Id id = 0;

  @Index(type: IndexType.value)
  String uid;

  String email;
  bool isAdmin = false;
  String firstName;
  String lastName;
  String licensePlate;
  String homeAddress;
  String workAddress;

  IsarUser(
      {required this.uid,
      required this.email,
      required this.isAdmin,
      required this.firstName,
      required this.lastName,
      required this.licensePlate,
      required this.homeAddress,
      required this.workAddress});
}
