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

  String _getErrorMessage(String errorString) {
    if (errorString.contains('không có kết nối mạng')) {
      return 'Không có kết nối mạng. Vui lòng kiểm tra lại kết nối internet của bạn.';
    } else if (errorString.contains('404') || errorString.contains('không tìm thấy thành phố')) {
      return 'Không tìm thấy thành phố.';
    } else if (errorString.contains('dioexception') || errorString.contains('socketexception') || 
               errorString.contains('connection errored') || errorString.contains('failed host lookup')) {
      return 'Lỗi kết nối mạng hoặc máy chủ. Vui lòng thử lại.';
    } else if (errorString.contains('401') || errorString.contains('invalid api key')) {
      return 'API key không hợp lệ hoặc hết hạn.';
    } else {
      return 'Đã có lỗi không mong muốn xảy ra. Vui lòng thử lại sau.';
    }
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
      emit(WeatherLoadSuccess(weatherData, forecastData, event.city, allowNewSearch: false));

    } catch (e) {
      print('BLoC: Error in _onWeatherRequested: ${e.toString()}');
      final errorString = e.toString().toLowerCase();
      final displayMessage = _getErrorMessage(errorString);
      emit(WeatherLoadFailure(displayMessage));
    }
  }

  Future<void> _onWeatherRequestedByCoords(
      WeatherRequestedCoords event,
      Emitter<WeatherState> emit,
      ) async {
    emit(WeatherLoadInProgress());
    print('BLoC: Received WeatherRequestedByCoords for lat=${event.lat}, lon=${event.lon}');

    try {
      print('BLoC: Calling getCurrentWeatherByCoords and getForecastData concurrently...');
      final results = await Future.wait([
        weatherRepository.getCurrentWeatherCoords(lat: event.lat, lon: event.lon),
        weatherRepository.getForecastData(lat: event.lat, lon: event.lon)
      ]);

      if (results.length == 2 && results[0] is WeatherData && results[1] is ForecastData) {
        final weatherData = results[0] as WeatherData;
        final forecastData = results[1] as ForecastData;

        print('BLoC: Fetched current weather and forecast successfully by coords.');
        emit(WeatherLoadSuccess(weatherData, forecastData, event.selectedName, allowNewSearch: false));
      } else {
        print('BLoC: Error processing results from Future.wait');
        throw Exception('Lỗi xử lý dữ liệu trả về từ API.');
      }

    } catch (e) {
      print('BLoC: Error in _onWeatherRequestedByCoords: ${e.toString()}');
      final errorString = e.toString().toLowerCase();
      final displayMessage = _getErrorMessage(errorString);
      emit(WeatherLoadFailure(displayMessage));
    }
  }
  /// Xử lý khi người dùng thay đổi input sau khi đã có kết quả thành công
  void _onUserInputChanged(UserInputChanged event, Emitter<WeatherState> emit) {
    final currentState = state;
    if (currentState is WeatherLoadSuccess && !currentState.allowNewSearch) {
      print('BLoC: User input changed after success. Allowing new search.');
      emit(currentState.copyWith(allowNewSearch: true));
    }
  }
}