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
}
