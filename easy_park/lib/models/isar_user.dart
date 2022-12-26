import 'package:isar/isar.dart';

part 'isar_user.g.dart';

@collection
class IsarUser {
  final Id id = 0;

  @Index(type: IndexType.value)
  String uid;

  String email;
  bool isAdmin = false;

  IsarUser({required this.uid, required this.email, required this.isAdmin});
}
