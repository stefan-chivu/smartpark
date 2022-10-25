import 'package:easy_park/models/parking_info.dart';
import 'package:mysql_client/mysql_client.dart';

class SqlService {
  final pool = MySQLConnectionPool(
    host: const String.fromEnvironment('EASYPARK_SQL_HOST'),
    port: 3306,
    userName: const String.fromEnvironment('EASYPARK_SQL_USERNAME'),
    password: const String.fromEnvironment('EASYPARK_SQL_PASSWORD'),
    maxConnections: 10,
    databaseName: 'easypark',
    secure: true,
  );

  //TODO: Add more specific parameters
  // i.e. town for narrower query
  Future<List<ParkingInfo>> getParkingSpots() async {
    List<ParkingInfo> parkingInfo = List.empty(growable: true);
    print("Attempting SQL Connection");
    var result = await pool.execute("SELECT * FROM Sensors");
    print("Fetched SQL info");

    for (var row in result.rows) {
      int id = row.typedColByName<int>("ID")!;
      bool occupied = row.typedColByName<bool>("OCCUPIED")!;
      double lat = row.typedColByName<double>("LATITUDE")!;
      double long = row.typedColByName<double>("LONGITUDE")!;

      parkingInfo.add(ParkingInfo(id, occupied, lat, long));
    }
    return parkingInfo;
  }
}
