abstract class Constants {
  static const String sqlHost = String.fromEnvironment('SMARTPARK_SQL_HOST');
  static const String sqlUserName =
      String.fromEnvironment('SMARTPARK_SQL_USERNAME');
  static const String sqlPassword =
      String.fromEnvironment('SMARTPARK_SQL_PASSWORD');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static final alNumRegExp = RegExp(r'^[a-zA-Z0-9]+$');
  static final nameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z\-]*[a-zA-Z]$');
  static const timeoutDuration = Duration(seconds: 7);
  static const sqlTimeoutDuration = Duration(seconds: 5);
  static const String sqlTimeoutMessage = 'SQL connection timed out';
}
