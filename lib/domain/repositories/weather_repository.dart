import 'package:weather_app/domain/entities/location_suggestion.dart';
import '../entities/weather.dart';
import '../entities/forecast_data.dart';

abstract class WeatherRepository {
  /// Lấy thông tin thời tiết hiện tại cho một thành phố cụ thể.
  ///
  /// Ném ra [Exception] nếu có lỗi xảy ra.
  Future<WeatherData> getWeatherByCity(String city);

  Future<List<LocationSuggestion>> getCitySuggestions(String query);

  Future<ForecastData> getForecastData({required double lat, required double lon});

  Future<WeatherData> getCurrentWeatherCoords({ double? lat, double? lon});
}
