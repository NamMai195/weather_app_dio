import 'package:bloc/bloc.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart';
import '../../domain/entities/forecast_data.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';


class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial()) {
    on<WeatherRequested>(_onWeatherRequested);
    on<WeatherRequestedCoords>(_onWeatherRequestedByCoords);
  }

  Future<void> _onWeatherRequested(
      WeatherRequested event,
      Emitter<WeatherState> emit,
      ) async {
    final String city = event.city;
    emit(WeatherLoadInProgress());
    print('BLoC: Received WeatherRequested for city: $city');
    try {
      final weatherData = await weatherRepository.getWeatherByCity(event.city);
      final lat = weatherData.coord.lat;
      final lon = weatherData.coord.lon;
      print('BLoC: Fetching forecast for city ($city) at Lat=$lat, Lon=$lon');
      final forecastData = await weatherRepository.getForecastData(lat: lat, lon: lon);

      print('BLoC: Fetched current weather and forecast successfully for city: $city');
      emit(WeatherLoadSuccess(weatherData, forecastData,event.city)); // Gửi state thành công với cả 2 data

    } catch (e) {
      print('BLoC: Error in _onWeatherRequested: ${e.toString()}');
      // TODO: Cải thiện message lỗi
      emit(WeatherLoadFailure('Lỗi khi tìm theo tên TP: ${e.toString()}'));
    }
  }

  // --- BỘ XỬ LÝ CHO EVENT TÌM THEO TỌA ĐỘ ---
  Future<void> _onWeatherRequestedByCoords(
      WeatherRequestedCoords event,
      Emitter<WeatherState> emit,
      ) async {
    emit(WeatherLoadInProgress()); // Bắt đầu trạng thái loading
    print('BLoC: Received WeatherRequestedByCoords for lat=${event.lat}, lon=${event.lon}');
      // Sau khi có WeatherData (chứa coord), gọi thêm hàm lấy forecast

    try {
      print('BLoC: Calling getCurrentWeatherByCoords and getForecastData concurrently...');
      // Gọi đồng thời API lấy thời tiết hiện tại và dự báo bằng Future.wait
      // Sử dụng các hàm repo nhận trực tiếp tọa độ
      final results = await Future.wait([
        weatherRepository.getCurrentWeatherCoords(lat: event.lat, lon: event.lon),
        weatherRepository.getForecastData(lat: event.lat, lon: event.lon)
      ]);

      // Kiểm tra kiểu dữ liệu trả về
      if (results.length == 2 && results[0] is WeatherData && results[1] is ForecastData) {
        final weatherData = results[0] as WeatherData;
        final forecastData = results[1] as ForecastData;

        print('BLoC: Fetched current weather and forecast successfully by coords.');
        // Thành công -> Phát ra state Success kèm cả 2 dữ liệu
        emit(WeatherLoadSuccess(weatherData, forecastData, event.selectedName));
      } else {
        print('BLoC: Error processing results from Future.wait');
        throw Exception('Lỗi xử lý dữ liệu trả về từ API.');
      }

    } catch (e) {
      // Thất bại -> Phát ra state Failure kèm thông báo lỗi
      print('BLoC: Error in _onWeatherRequestedByCoords: ${e.toString()}');
      // TODO: Cải thiện message lỗi
      emit(WeatherLoadFailure('Lỗi khi tìm theo tọa độ: ${e.toString()}'));
    }
  }
// --- KẾT THÚC BỘ XỬ LÝ MỚI ---
}