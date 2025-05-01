import 'dart:convert';

import 'package:weather_app/domain/entities/location_suggestion.dart';

import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherData> getWeatherByCity(String city) async {
    try {
      final Map<String, dynamic> jsonMap = await remoteDataSource
          .getCurrentWeather(city);

      final WeatherData weatherData = WeatherData.fromJson(jsonMap);

      return weatherData;
    } catch (e) {
      print('WeatherRepositoryImpl Error: ${e.toString()}');
      throw Exception('Không thể lấy dữ liệu thời tiết: ${e.toString()}');
    }
  }

  @override
  Future<List<LocationSuggestion>> getCitySuggestions(String query) async {
    // Nếu query rỗng thì không cần gọi API, trả về list rỗng luôn
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> rawSuggestions = await remoteDataSource.getCitySuggestionDate(query);


      final suggestions = rawSuggestions.map((json) {
        if (json is Map<String, dynamic>) {
          final name = json['name'] as String?;
          final country = json['country'] as String?;
          final state = json['state'] as String?;

          if (name != null) {
            return LocationSuggestion(
              name: name,
              country: country,
              state: state,
            );
          }
        }
        return null;
      }).whereType<LocationSuggestion>().toList();

      return suggestions;

    } catch (e) {
      print('WeatherRepositoryImpl Error (getCitySuggestions): ${e.toString()}');
      return [];
    }
  }
}
