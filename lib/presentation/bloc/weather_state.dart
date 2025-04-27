import 'package:equatable/equatable.dart';

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
  // const WeatherLoadSuccess(this.weather);
  // final Weather weather; // Sẽ thêm model Weather ở đây sau

  // @override
  // List<Object> get props => [weather];
}

// Trạng thái tải dữ liệu thất bại
class WeatherLoadFailure extends WeatherState {
  const WeatherLoadFailure(this.message);
  final String message; // Thông báo lỗi

  @override
  List<Object> get props => [message];
}