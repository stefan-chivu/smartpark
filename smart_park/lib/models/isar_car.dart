import 'package:isar/isar.dart';

part 'isar_car.g.dart';

@collection
class IsarCar {
  final Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  int? carId;
  @Index(type: IndexType.value)
  String ownerUid;
  @Index(type: IndexType.value, unique: true)
  String licensePlate;
  bool isElectric;

  IsarCar(
      {this.carId,
      required this.ownerUid,
      required this.licensePlate,
      required this.isElectric});
}
