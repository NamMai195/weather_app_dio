// lib/presentation/bloc/weather_bloc.dart
import 'package:bloc/bloc.dart'; // Import thư viện Bloc
import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/entities/weather.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart'; // Import Equatable



class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial()) {
    on<WeatherRequested>(_onWeatherRequested);
  }

  // Hàm xử lý sự kiện WeatherRequested
  Future<void> _onWeatherRequested(
      WeatherRequested event,
      Emitter<WeatherState> emit,
      ) async {
    final String city = event.city;
    emit(WeatherLoadInProgress()); // Bắt đầu trạng thái loading

    try {
      // Gọi repository thật sự để lấy dữ liệu
      final WeatherData weatherData = await weatherRepository.getWeatherByCity(city);

      // Thành công -> Phát ra state Success kèm dữ liệu nhận được
      emit(WeatherLoadSuccess(weatherData));

    } catch (e) {
      // Thất bại -> Phát ra state Failure kèm thông báo lỗi
      // Lỗi này được ném ra từ RepositoryImpl hoặc DataSourceImpl
      emit(WeatherLoadFailure(e.toString()));
    }
  }
}