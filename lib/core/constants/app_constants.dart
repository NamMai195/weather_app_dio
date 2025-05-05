class ApiConstants {
  ApiConstants._();

  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  static const String geocodingBaseUrl = 'https://api.openweathermap.org/geo/1.0';

  static const String weatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  static const String geocodingDirectEndpoint = '/direct';

  static const String weatherIconBaseUrl = 'https://openweathermap.org/img/wn/';
  static const String weatherIconSuffix = '@2x.png';

}

class AppConstants {
  AppConstants._();

  static const String appTitle = 'Weather App';

  static const int debounceDurationMs = 500;
}

