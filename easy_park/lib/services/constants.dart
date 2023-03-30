abstract class Constants {
  static const String sqlHost = String.fromEnvironment('EASYPARK_SQL_HOST');
  static const String sqlUserName =
      String.fromEnvironment('EASYPARK_SQL_USERNAME');
  static const String sqlPassword =
      String.fromEnvironment('EASYPARK_SQL_PASSWORD');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static final alNumRegExp = RegExp(r'^[a-zA-Z0-9]+$');
  static final nameRegExp = RegExp(r'^[a-zA-Z][a-zA-Z\-]*[a-zA-Z]$');
}
