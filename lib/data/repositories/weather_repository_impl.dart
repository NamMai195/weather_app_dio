// lib/data/repositories/weather_repository_impl.dart

import '../../domain/entities/weather.dart'; // Import model WeatherData
import '../../domain/repositories/weather_repository.dart'; // Import interface repository
import '../datasources/weather_remote_datasource.dart'; // Import data source

// Lớp triển khai WeatherRepository interface
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource; // Inject remote data source

  WeatherRepositoryImpl({required this.remoteDataSource}); // Constructor

  @override
  Future<WeatherData> getWeatherByCity(String city) async {
    try {
      // 1. Gọi phương thức từ remote data source để lấy dữ liệu JSON thô
      final Map<String, dynamic> jsonMap = await remoteDataSource.getCurrentWeather(city);

      // 2. Dùng factory method `fromJson` của model WeatherData để parse JSON map thành đối tượng Dart
      final WeatherData weatherData = WeatherData.fromJson(jsonMap);

      // 3. Trả về đối tượng WeatherData đã được parse
      return weatherData;

    } catch (e) {
      // Nếu có lỗi từ data source (mạng, API...), bắt lỗi và ném lại
      // Sau này có thể xử lý lỗi chi tiết hơn, ví dụ: chuyển thành các loại lỗi cụ thể của domain
      print('WeatherRepositoryImpl Error: ${e.toString()}');
      // Ném lại lỗi để tầng trên (BLoC) có thể xử lý
      throw Exception('Không thể lấy dữ liệu thời tiết: ${e.toString()}');
    }
  }
}