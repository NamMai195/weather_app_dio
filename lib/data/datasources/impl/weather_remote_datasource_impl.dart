import 'package:dio/dio.dart';
import 'package:weather_app/config.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import '../weather_remote_datasource.dart';

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  final String apiKey = openWeatherApiKey;


  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getCurrentWeather({
    String? cityName,
    double? lat,
    double? lon,
  }) async {
    // Input Validation
    final bool hasCityName = cityName != null && cityName.isNotEmpty;
    final bool hasCoordinates = lat != null && lon != null;

    if (!hasCityName && !hasCoordinates) {
      throw ArgumentError('Cần cung cấp cityName hoặc cả lat và lon.');
    }
    // Không cần warning nếu ưu tiên tọa độ

    final Map<String, dynamic> queryParameters = {
      'appid': apiKey,
      'units': 'metric',
      'lang': 'vi', // Thêm lang=vi nếu muốn kết quả tiếng Việt
    };

    // Xây dựng Query Parameters dựa trên input
    if (hasCoordinates) {
      queryParameters['lat'] = lat;
      queryParameters['lon'] = lon;
      print("Fetching weather using coordinates: lat=$lat, lon=$lon");
    } else { // Chỉ dùng cityName nếu không có tọa độ
      queryParameters['q'] = cityName;
      print("Fetching weather using city name: $cityName");
    }

    final url = '${ApiConstants.weatherBaseUrl}${ApiConstants.weatherEndpoint}'; // Dùng hằng số
    print('API Request URL: $url');
    print('API Request Params: $queryParameters');

    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        print('API Response Data: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Lỗi API thời tiết: ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('DioException in getCurrentWeather: ${e.response?.data ?? e.message}');
      rethrow; // Ném lại để Repository xử lý
    } catch (e) {
      print('Unexpected error in getCurrentWeather: $e');
      throw Exception('Lỗi không xác định khi lấy dữ liệu thời tiết.');
    }
  }

  @override
  Future<List<dynamic>> getCitySuggestionData(String query, {int limit = 5}) async {
    final url = '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingDirectEndpoint}'; // Dùng hằng số
    final queryParameters = {
      'q': query,
      'limit': limit,
      'appid': apiKey,
    };
    print('Geocoding Request URL: $url');
    print('Geocoding Request Params: $queryParameters');

    try {
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data is List) {
        print('Geocoding Response Data: ${response.data}');
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Lỗi API Geocoding: ${response.statusCode}',
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('DioException in getCitySuggestionData: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error in getCitySuggestionData: $e');
      throw Exception('Lỗi không xác định khi lấy gợi ý thành phố.');
    }
  }

  @override
  Future<Map<String, dynamic>> getForecastWeather({
    String? cityName,
    double? lat,
    double? lon}) async{
    final bool hasCityName = cityName !=null && cityName.isNotEmpty;
    final bool hasCoordinates = lat != null && lon != null;

    if(!hasCityName && !hasCoordinates){
      throw ArgumentError('Can cung cap cityName hoac ca lat va lon.');
    }
    final Map<String, dynamic> queryParameters = {
      'appid': apiKey,
      'units': 'metric',
      'lang': 'vi',
    };

    //Xay dung query parameters dua tren toa do
    if(hasCoordinates) {
      queryParameters['lat'] =lat;
      queryParameters['lon'] =lon;
      print('Fetching forcast using city name: $cityName');
    } else {
      queryParameters['q'] =cityName;
      print('Fetching forecast using city name: $cityName');
    }

    //endpoint cho du lieu dự báo thời tiết 5 ngày
    final url = '${ApiConstants.weatherBaseUrl}${ApiConstants.forecastEndpoint}'; // Dùng hằng số

    print('API Request URL: $url');
    print('API Request Params: $queryParameters');

    try{
      final reponse = await dio.get(url,queryParameters: queryParameters);

      if(reponse.statusCode==200) {
        print('API Response Data: ${reponse.data}');
        return reponse.data as Map<String, dynamic>;
      } else {
        throw DioException(requestOptions: reponse.requestOptions,
        response: reponse,error: 'Lỗi API dự báo thời tiết: ${reponse.statusCode}',
        type: DioExceptionType.badResponse);
      }
    } on DioException catch (e) {
      print('DioException in getForecastWeather: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error in getForecastWeather: $e');
      throw Exception('Lỗi không xác định khi lấy dữ liệu dự báo thời tiết.');
    }
  }
}