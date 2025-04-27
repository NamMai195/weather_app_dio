import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

// Sự kiện yêu cầu lấy thông tin thời tiết cho một thành phố
class WeatherRequested extends WeatherEvent {
  const WeatherRequested(this.city);
  final String city; // Tên thành phố cần tìm

  @override
  List<Object> get props => [city];
}

// Có thể thêm các event khác sau này nếu cần (ví dụ: RefreshWeather)
