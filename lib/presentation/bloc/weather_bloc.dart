// lib/presentation/bloc/weather_bloc.dart
import 'package:bloc/bloc.dart'; // Import thư viện Bloc
import 'package:equatable/equatable.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart'; // Import Equatable



class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  // Repository sẽ được inject vào đây sau
  // final WeatherRepository weatherRepository;

  // Constructor: Thiết lập trạng thái ban đầu là WeatherInitial
  WeatherBloc(/*{required this.weatherRepository}*/) : super(WeatherInitial()) {
    // Đăng ký bộ xử lý cho sự kiện WeatherRequested
    on<WeatherRequested>(_onWeatherRequested);
  }

  // Hàm xử lý sự kiện WeatherRequested
  Future<void> _onWeatherRequested(
      WeatherRequested event,
      Emitter<WeatherState> emit,
      ) async {
    // Lấy tên thành phố từ sự kiện
    final String city = event.city;

    // Phát ra trạng thái đang tải
    emit(WeatherLoadInProgress());

    try {
      // ----- PHẦN GỌI API SẼ THAY THẾ Ở ĐÂY SAU -----
      // Hiện tại, chúng ta sẽ giả lập việc gọi API

      print('BLoC: Nhận được yêu cầu cho thành phố: $city. Giả lập gọi API...');
      await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ mạng

      // Giả lập thành công (chưa có data) hoặc thất bại
      bool simulateSuccess = true; // Thay đổi thành false để test trạng thái lỗi

      if (simulateSuccess) {
        print('BLoC: Giả lập gọi API thành công.');
        // Sẽ thay thế bằng emit(WeatherLoadSuccess(weatherData)); khi có model và data
        emit(WeatherLoadSuccess());
      } else {
        print('BLoC: Giả lập gọi API thất bại.');
        emit(const WeatherLoadFailure("Lỗi giả lập từ BLoC"));
      }
      // ----- KẾT THÚC PHẦN GIẢ LẬP -----

    } catch (e) {
      // Xử lý lỗi thực tế (nếu có) khi gọi API sau này
      print('BLoC: Có lỗi xảy ra - ${e.toString()}');
      emit(WeatherLoadFailure(e.toString()));
    }
  }
}