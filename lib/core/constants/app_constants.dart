// lib/core/constants/app_constants.dart

// Lớp chứa các hằng số liên quan đến API
class ApiConstants {
  // Private constructor để ngăn việc tạo instance của lớp này
  ApiConstants._();

  // Base URL cho các API thời tiết của OpenWeatherMap
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  // Base URL cho API Geocoding
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
  // Text
  static const String searchHintText = 'Nhập hoặc chọn thành phố';
  static const String searchButtonText = 'Xem Thời Tiết';
  static const String initialMessage = 'Nhập tên thành phố và nhấn nút để xem thời tiết.';
  static const String forecastTitle = 'Dự báo 5 ngày tới';
  static const String noForecastData = 'Không có dữ liệu dự báo theo ngày.';
  static const String noSuggestions = 'Không tìm thấy gợi ý.';
  static const String errorDialogTitle = 'Lỗi';
  static const String errorDialogButton = 'OK';
  // Durations
  static const int debounceDurationMs = 500;
}
