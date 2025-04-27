import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/entities/weather.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => []; // Props dùng để Equatable so sánh các đối tượng
}

// Trạng thái ban đầu, chưa có hành động gì
class WeatherInitial extends WeatherState {}

// Trạng thái đang tải dữ liệu từ API
class WeatherLoadInProgress extends WeatherState {}

// Trạng thái tải dữ liệu thành công
// Tạm thời chưa có data, sẽ thêm sau khi có Model
class WeatherLoadSuccess extends WeatherState {
  const WeatherLoadSuccess(
    this.weatherData,
  ); // Nhận WeatherData qua constructor
  final WeatherData weatherData; // Thêm trường để giữ dữ liệu

  @override
  List<Object> get props => [weatherData]; // Thêm vào props để Equatable so sánh
}

// Trạng thái tải dữ liệu thất bại
class WeatherLoadFailure extends WeatherState {
  const WeatherLoadFailure(this.message);
  final String message; // Thông báo lỗi

  @override
  List<Object> get props => [message];
}
