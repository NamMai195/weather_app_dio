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

class WeatherRequestedCoords extends WeatherEvent {
  const WeatherRequestedCoords({
    required this.lat,
    required this.lon,
    required this.selectedName,
  });

  final double lat;
  final double lon;
  final String selectedName;

  @override
  List<Object> get props => [lat, lon, selectedName];
}

