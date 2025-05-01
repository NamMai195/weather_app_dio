import 'package:dio/dio.dart';
import 'package:weather_app/config.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  final String apiKey = openWeatherApiKey;
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5';

  final String geocodingBaseUrl ='https://api.openweathermap.org/geo/1.0';

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

  @override
  Future<List<dynamic>> getCitySuggestionDate(String query) async{
    final url='$geocodingBaseUrl/direct';
    final queryParameters={
      'q' :query,
      'limit':5,
      'appid' :apiKey,
    };
    print('Geocoding Request URL :$url');
    print('Geocoding Request Params: $queryParameters');

    try {
      final response = await dio.get(
          url,
          queryParameters: queryParameters
      );
      if(response.statusCode == 200) {
        if(response.data is List) {
          print('Geocoding Response Data: ${response.data}');
          return response.data as List<dynamic>;
        } else {
          throw Exception('API Geocoding khong tra ve dinh dang List mong doi');
        }
      } else {
        throw Exception('Loi server Geocoding: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Loi mang hoac API Geocoding : ${e.message}');
    } catch (e) {
      throw Exception('Loi khong xac dinh khi goi Geocoding: ${e.toString()}');
    }
  }
}