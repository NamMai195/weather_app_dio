// lib/data/datasources/weather_remote_datasource.dart

import 'package:dio/dio.dart'; // Import thư viện Dio
import '../../config.dart'; // Import file config chứa API key

// Định nghĩa lớp trừu tượng (tùy chọn, nhưng tốt cho việc testing/dependency inversion)
abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentWeather(String city);
}

// Lớp triển khai việc gọi API thời tiết
class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio; // Inject Dio instance
  final String apiKey = openWeatherApiKey; // Lấy API key từ config
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5'; // Base URL của API

  WeatherRemoteDataSourceImpl({required this.dio}); // Constructor nhận Dio

  @override
  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    // Xây dựng URL đầy đủ
    final url = '$baseUrl/weather';

    // Tham số truy vấn (query parameters)
    final queryParameters = {
      'q': city,
      'appid': apiKey,
      'units': 'metric', // Đơn vị metric (Celsius)
      // 'lang': 'vi', // Có thể thêm để nhận mô tả tiếng Việt nếu API hỗ trợ
    };

    print('API Request URL: $url');
    print('API Request Params: $queryParameters');

    try {
      // Thực hiện GET request bằng Dio
      final response = await dio.get(url, queryParameters: queryParameters);

      // Kiểm tra status code thành công (200 OK)
      if (response.statusCode == 200) {
        print('API Response Data: ${response.data}');
        // Dio tự động decode JSON thành Map<String, dynamic>
        return response.data as Map<String, dynamic>;
      } else {
        // Ném lỗi nếu status code không phải 200
        print('API Error: Status Code ${response.statusCode}');
        throw Exception('Lỗi server: ${response.statusCode}'); // Ném lỗi chung
      }
    } on DioException catch (e) {
      // Xử lý các lỗi từ Dio (ví dụ: không có mạng, timeout, lỗi server cụ thể hơn)
      print('DioException: ${e.message}');
      // Có thể phân tích e.response?.statusCode để biết lỗi cụ thể
      // hoặc e.type để biết loại lỗi (connectionTimeout, receiveTimeout, etc.)
      throw Exception('Lỗi mạng hoặc API: ${e.message}'); // Ném lỗi chung
    } catch (e) {
      // Bắt các lỗi khác không mong muốn
      print('Unexpected Error: ${e.toString()}');
      throw Exception('Lỗi không xác định: ${e.toString()}'); // Ném lỗi chung
    }
  }
}
