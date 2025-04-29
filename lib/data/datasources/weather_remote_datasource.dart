import 'package:dio/dio.dart';
import '../../config.dart';

abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentWeather(String city);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  final String apiKey = openWeatherApiKey;
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5';

  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final url = '$baseUrl/weather';

    final queryParameters = {
      'q': city,
      'appid': apiKey,
      'units': 'metric',
    };

    print('API Request URL: $url');
    print('API Request Params: $queryParameters');

    try {
      final response = await dio.get(url, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        print('API Response Data: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('API Error: Status Code ${response.statusCode}');
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      throw Exception('Lỗi mạng hoặc API: ${e.message}');
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
      throw Exception('Lỗi không xác định: ${e.toString()}');
    }
  }
}
