import 'package:easy_park/models/parking_history.dart';
import 'package:easy_park/services/sql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentHistoryProvider =
    FutureProvider.autoDispose<List<ParkingPayment>>((ref) async {
  final List<ParkingPayment> parkingHistory =
      await SqlService.getUserParkingHistory();
  return parkingHistory;
});
