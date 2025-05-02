import 'package:weather_app/domain/entities/forecast_data.dart';

import '../../domain/entities/location_suggestion.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      print('Repository: Lấy tọa độ cho: $cityName');
      final List<dynamic> suggestionData = await remoteDataSource.getCitySuggestionData(cityName, limit: 1);

      if (suggestionData.isEmpty) {
        print('Repository: Không tìm thấy gợi ý (tọa độ) cho $cityName');
        throw Exception('Không tìm thấy thành phố: $cityName');
      }

      final Map<String, dynamic> firstSuggestionMap = suggestionData.first as Map<String, dynamic>;
      final double? lat = firstSuggestionMap['lat'] as double?;
      final double? lon = firstSuggestionMap['lon'] as double?;


      if (lat == null || lon == null) {
        print('Repository: Dữ liệu gợi ý không có tọa độ hợp lệ cho $cityName. Data: $firstSuggestionMap');
        throw Exception('Không thể xác định vị trí cho: $cityName');
      }
      print('Repository: Tọa độ tìm được: Lat=$lat, Lon=$lon');

      print('Repository: Lấy thời tiết cho tọa độ: Lat=$lat, Lon=$lon');
      final Map<String, dynamic> weatherJsonMap = await remoteDataSource.getCurrentWeather(lat: lat, lon: lon);

      print('Repository: Parse dữ liệu thời tiết...');
      final WeatherData weatherData = WeatherData.fromJson(weatherJsonMap);
      return weatherData;

    } catch (e) {
      print('WeatherRepositoryImpl Error (getWeatherByCity): ${e.toString()}');
      throw Exception('Không thể lấy dữ liệu thời tiết: ${e.toString()}');
    }
  }

  @override
  Future<List<LocationSuggestion>> getCitySuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> rawSuggestions = await remoteDataSource.getCitySuggestionData(query);

      final suggestions = rawSuggestions.map((json) {
        if (json is Map<String, dynamic>) {
          final name = json['name'] as String?;
          final country = json['country'] as String?;
          final state = json['state'] as String?;

          final lat = json['lat'] as double?;
          final lon = json['lon'] as double?;

          if (name != null) {
            return LocationSuggestion(
              name: name,
              country: country,
              state: state,
              lat: lat,
              lon: lon,
            );
          }
        }
        return null;
      }).whereType<LocationSuggestion>().toList();

      // Sắp xếp ưu tiên Việt Nam (nếu muốn giữ logic này)
      suggestions.sort((a, b) {
        bool aIsVn = (a.country?.toUpperCase() == 'VN');
        bool bIsVn = (b.country?.toUpperCase() == 'VN');
        if (aIsVn && !bIsVn) return -1;
        if (!aIsVn && bIsVn) return 1;
        return 0;
      });

      return suggestions;

    } catch (e) {
      print('WeatherRepositoryImpl Error (getCitySuggestions): ${e.toString()}');
      return [];
    }
  }

  @override
  Future<ForecastData> getForecastData({required double lat, required double lon}) async{
    try {
      print('Repository: Lấy dự báo thời tiết cho tọa độ: Lat=$lat, Lon=$lon');
      final Map<String, dynamic> rawForecastData = await remoteDataSource.getForecastWeather(lat: lat, lon: lon);

      print('Repository: Parse');
      final ForecastData forecastData=ForecastData.fromJson(rawForecastData);
      return forecastData;
    } catch (e) {
      print('WeatherRepositoryImpl Error(getForecastDate): ${e.toString()}');
      throw Exception('Khong the lay du lieu dự báo thời tiết: ${e.toString()}');
    }
  }

  @override
  Future<WeatherData> getCurrentWeatherCoords({double? lat, double? lon}) async{
    try{
      print('Repository: lấy thời tiết hiện tại cho tọa độ: Lat=$lat, Lon=$lon');
      final Map<String,dynamic> weatherJsonMap = await remoteDataSource.getCurrentWeather(lat: lat,lon: lon);
      print('Repository: Parse dữ liệu thời tiết...');
      final WeatherData weatherData=WeatherData.fromJson(weatherJsonMap);
      return weatherData;
    } catch (e) {
      print('WeatherRepositoryImpl Error:${e.toString()}');
      throw Exception('Khong thể lấy dữ liệu thời tiết hiện tại: ${e.toString()}');
    }
  }
}