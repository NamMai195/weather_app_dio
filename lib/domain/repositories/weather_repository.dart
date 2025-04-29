import '../entities/weather.dart';

abstract class WeatherRepository {
  /// Lấy thông tin thời tiết hiện tại cho một thành phố cụ thể.
  ///
  /// Ném ra [Exception] nếu có lỗi xảy ra.
  Future<WeatherData> getWeatherByCity(String city);
}
