abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentWeather({
    String? cityName,
    double? lat,
    double? lon,
  });

  Future<List<dynamic>> getCitySuggestionData(String query, {int limit = 5});

  // Thêm phương thức lấy dự báo thời tiết
  Future<Map<String, dynamic>> getForecastWeather({
    String? cityName,
    double? lat,
    double? lon,
  });
}