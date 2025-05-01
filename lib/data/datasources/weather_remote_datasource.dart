// lib/data/datasources/weather_remote_datasource.dart
// Đã cập nhật getCurrentWeather

abstract class WeatherRemoteDataSource {
  // Sửa lại hàm này: có thể nhận cityName hoặc lat/lon
  Future<Map<String, dynamic>> getCurrentWeather({
    String? cityName, // Thêm dấu ? để cho phép null
    double? lat,      // Thêm lat
    double? lon,      // Thêm lon
  });

  // Hàm này giữ nguyên (sửa lại tên nếu cần)
  Future<List<dynamic>> getCitySuggestionData(String query, {int limit = 5});
}