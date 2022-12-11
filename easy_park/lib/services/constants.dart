abstract class Constants {
  static const String sqlHost = String.fromEnvironment('EASYPARK_SQL_HOST');
  static const String sqlUserName =
      String.fromEnvironment('EASYPARK_SQL_USERNAME');
  static const String sqlPassword =
      String.fromEnvironment('EASYPARK_SQL_PASSWORD');
  static const String firebaseWebApiKey =
      String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const String firebaseWebAuthDomain =
      String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN');
  static const String firebaseWebProjectId =
      String.fromEnvironment('FIREBASE_WEB_PROJECT_ID');
  static const String firebaseWebStorageBucket =
      String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET');
  static const String firebaseWebMessagingSenderId =
      String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID');
  static const String firebaseWebAppId =
      String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String firebaseWebMeasurementId =
      String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID');
}
