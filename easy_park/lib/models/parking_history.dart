import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/models/spot_info.dart';

class ParkingPayment {
  int id;
  SpotInfo spot;
  final IsarCar car;
  double totalSum;
  final DateTime timestamp;
  final DateTime parkingStart;
  final DateTime parkingEnd;

  ParkingPayment(
      {required this.id,
      required this.spot,
      required this.car,
      required this.totalSum,
      required this.timestamp,
      required this.parkingStart,
      required this.parkingEnd});
}
