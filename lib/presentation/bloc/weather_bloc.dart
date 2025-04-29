import 'package:bloc/bloc.dart';
import 'package:weather_app/domain/entities/weather.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart'; // Import Equatable

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial()) {
    on<WeatherRequested>(_onWeatherRequested);
  }

  Future<void> _onWeatherRequested(
    WeatherRequested event,
    Emitter<WeatherState> emit,
  ) async {
    final String city = event.city;
    emit(WeatherLoadInProgress());

    try {
      final WeatherData weatherData = await weatherRepository.getWeatherByCity(
        city,
      );

      emit(WeatherLoadSuccess(weatherData));
    } catch (e) {
      emit(WeatherLoadFailure(e.toString()));
    }
  }
}
