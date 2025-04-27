// lib/domain/repositories/weather_repository.dart

import '../entities/weather.dart'; // Import model WeatherData đã tạo

// Định nghĩa lớp trừu tượng (interface) cho Weather Repository
abstract class WeatherRepository {
  /// Lấy thông tin thời tiết hiện tại cho một thành phố cụ thể.
  ///
  /// Ném ra [Exception] nếu có lỗi xảy ra.
  Future<WeatherData> getWeatherByCity(String city);

// Có thể thêm các phương thức khác ở đây sau nếu cần
// Ví dụ: Future<ForecastData> getForecastByCity(String city);
}