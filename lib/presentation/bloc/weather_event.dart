import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class WeatherRequested extends WeatherEvent {
  const WeatherRequested(this.city);
  final String city; // Tên thành phố cần tìm

  @override
  List<Object> get props => [city];
}

