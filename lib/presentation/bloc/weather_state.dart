import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/entities/forecast_data.dart';
import 'package:weather_app/domain/entities/weather.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  const WeatherLoadSuccess(
    this.weatherData,this.forecastData,this.displayedCityName,
  );
  final WeatherData weatherData;
  final ForecastData forecastData;
  final String displayedCityName;
  @override
  List<Object> get props => [weatherData, forecastData, displayedCityName];
}

class WeatherLoadFailure extends WeatherState {
  const WeatherLoadFailure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
