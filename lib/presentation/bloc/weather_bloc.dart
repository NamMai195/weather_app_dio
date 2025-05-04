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
    on<UserInputChanged>(_onUserInputChanged);
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
      emit(WeatherLoadSuccess(weatherData, forecastData,event.city,allowNewSearch: false)); // Gửi state thành công với cả 2 data

    } catch (e) {
      print('BLoC: Error in _onWeatherRequested: ${e.toString()}');
      // --- SỬA PHẦN XỬ LÝ LỖI ---
      String displayMessage;
      final errorString = e.toString().toLowerCase(); // Chuyển về chữ thường để dễ so sánh

      if (errorString.contains('404') || errorString.contains('không tìm thấy thành phố')) {
        displayMessage = 'Không tìm thấy thành phố "${event.city}".';
      } else if (errorString.contains('dioexception') || errorString.contains('socketexception') || errorString.contains('connection errored') || errorString.contains('failed host lookup')) {
        displayMessage = 'Lỗi kết nối mạng hoặc máy chủ. Vui lòng thử lại.';
      } else if (errorString.contains('401') || errorString.contains('invalid api key')) {
        displayMessage = 'API key không hợp lệ hoặc hết hạn.'; // Xử lý lỗi API Key nếu muốn
      }
      else {
        displayMessage = 'Đã có lỗi không mong muốn xảy ra. Vui lòng thử lại sau.'; // Lỗi chung chung
      }
      emit(WeatherLoadFailure(displayMessage)); // Emit message thân thiện
      // --- KẾT THÚC SỬA ---
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
        emit(WeatherLoadSuccess(weatherData, forecastData, event.selectedName,allowNewSearch: false));
      } else {
        print('BLoC: Error processing results from Future.wait');
        throw Exception('Lỗi xử lý dữ liệu trả về từ API.');
      }

    } catch (e) {
      print('BLoC: Error in _onWeatherRequestedByCoords: ${e.toString()}');
      // --- SỬA PHẦN XỬ LÝ LỖI ---
      String displayMessage;
      final errorString = e.toString().toLowerCase();

      // Lỗi 404 với tọa độ thường ít xảy ra, nhưng có thể là lỗi server hoặc mạng
      if (errorString.contains('dioexception') || errorString.contains('socketexception') || errorString.contains('connection errored') || errorString.contains('failed host lookup')) {
        displayMessage = 'Lỗi kết nối mạng hoặc máy chủ. Vui lòng thử lại.';
      } else if (errorString.contains('401') || errorString.contains('invalid api key')) {
        displayMessage = 'API key không hợp lệ hoặc hết hạn.';
      }
      else {
        displayMessage = 'Đã có lỗi không mong muốn xảy ra khi tìm theo tọa độ.'; // Lỗi chung chung
      }
      emit(WeatherLoadFailure(displayMessage)); // Emit message thân thiện
      // --- KẾT THÚC SỬA ---
    }
  }
  // --- THÊM HÀM NÀY ---
  /// Xử lý khi người dùng thay đổi input sau khi đã có kết quả thành công
  void _onUserInputChanged(UserInputChanged event, Emitter<WeatherState> emit) {
    // Lấy state hiện tại
    final currentState = state;
    // Chỉ hành động nếu state hiện tại là Success và chưa cho phép tìm kiếm mới
    if (currentState is WeatherLoadSuccess && !currentState.allowNewSearch) {
      print('BLoC: User input changed after success. Allowing new search.');
      // Phát ra lại state Success nhưng với cờ allowNewSearch = true
      // Dùng copyWith để giữ nguyên các dữ liệu khác
      emit(currentState.copyWith(allowNewSearch: true));
    }
    // Nếu state không phải Success hoặc đã cho phép tìm mới rồi thì không cần làm gì cả
  }
// --- KẾT THÚC HÀM MỚI ---
}