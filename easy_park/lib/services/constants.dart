abstract class Constants {
  static const String sqlHost = String.fromEnvironment('EASYPARK_SQL_HOST');
  static const String sqlUserName =
      String.fromEnvironment('EASYPARK_SQL_USERNAME');
  static const String sqlPassword =
      String.fromEnvironment('EASYPARK_SQL_PASSWORD');
}
