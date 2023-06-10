import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/models/spot_info.dart';

enum PaymentState { ongoing, due, paid }

class ParkingPayment {
  int? id;
  SpotInfo spot;
  final IsarCar car;
  double totalSum;
  final DateTime? timestamp;
  final DateTime parkingStart;
  final DateTime? parkingEnd;
  final PaymentState state;
  final Duration parkingDuration;
  final int? startEntryId;
  final int? endEntryId;

  ParkingPayment(
      {this.id,
      required this.spot,
      required this.car,
      required this.totalSum,
      this.timestamp,
      required this.parkingStart,
      this.parkingEnd,
      required this.state,
      required this.parkingDuration,
      this.startEntryId,
      this.endEntryId});
}
