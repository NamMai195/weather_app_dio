// lib/presentation/screens/weather_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc library
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart';
import '../bloc/weather_bloc.dart';         // Import BLoC vừa tạo

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Cung cấp WeatherBloc cho cây widget con của màn hình này
    return BlocProvider(
      create: (context) => WeatherBloc(
        // Tạo và inject các dependencies cần thiết
        weatherRepository: WeatherRepositoryImpl(
          remoteDataSource: WeatherRemoteDataSourceImpl(
            dio: Dio(), // Tạo instance Dio mới ở đây
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        // Sử dụng BlocBuilder để lắng nghe và rebuild UI theo trạng thái BLoC
        body: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            // Phần UI chung không thay đổi nhiều theo state (ví dụ: Padding)
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Phần Input luôn hiển thị (có thể disable khi loading) ---
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập tên thành phố',
                      hintText: 'Ví dụ: Hanoi',
                      border: OutlineInputBorder(),
                    ),
                    // Vô hiệu hóa ô nhập khi đang tải
                    enabled: state is! WeatherLoadInProgress,
                  ),
                  const SizedBox(height: 20),

                  // Nút bấm để gửi sự kiện
                  ElevatedButton(
                    onPressed: (state is WeatherLoadInProgress)
                        ? null // Vô hiệu hóa nút khi đang tải
                        : () {
                      final cityName = _cityController.text;
                      if (cityName.isNotEmpty) {
                        // Gửi sự kiện WeatherRequested đến BLoC
                        context.read<WeatherBloc>().add(WeatherRequested(cityName));
                      }
                    },
                    child: const Text('Xem Thời Tiết'),
                  ),
                  const SizedBox(height: 30),

                  // --- Phần hiển thị kết quả thay đổi theo State ---
                  _buildWeatherContent(context, state),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Hàm helper để xây dựng phần nội dung dựa trên state
  // Hàm helper để xây dựng phần nội dung dựa trên state
  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      return const Center(
        child: Text(
          'Nhập tên thành phố và nhấn nút để xem thời tiết.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (state is WeatherLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is WeatherLoadSuccess) {
      // ---- PHẦN CẬP NHẬT ĐỂ HIỂN THỊ DATA ----
      // Lấy dữ liệu từ state
      final weatherData = state.weatherData;
      // Lấy thông tin icon (weather là list, thường chỉ cần phần tử đầu tiên)
      final weatherInfo = weatherData.weather.isNotEmpty ? weatherData.weather[0] : null;
      final iconCode = weatherInfo?.icon;
      final iconUrl = iconCode != null ? 'https://openweathermap.org/img/wn/$iconCode@2x.png' : null;

      return SingleChildScrollView( // Dùng SingleChildScrollView nếu nội dung có thể dài
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
          children: [
            Text(
              weatherData.name, // Tên thành phố
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (iconUrl != null)
              Image.network( // Hiển thị icon thời tiết từ URL
                iconUrl,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  // Hiển thị placeholder hoặc thông báo lỗi nếu không tải được ảnh
                  return const Icon(Icons.error_outline, size: 50);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox( // Placeholder khi đang tải ảnh
                    width: 100,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),

            if (weatherInfo != null)
              Text(
                weatherInfo.description, // Mô tả thời tiết
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 20),

            Text(
              '${weatherData.main.temp.toStringAsFixed(1)}°C', // Nhiệt độ (làm tròn 1 chữ số thập phân)
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row( // Hiển thị độ ẩm và tốc độ gió trên cùng một hàng
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Căn đều khoảng cách
              children: [
                Column(
                  children: [
                    const Text('Độ ẩm', style: TextStyle(fontSize: 16)),
                    Text('${weatherData.main.humidity}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Gió', style: TextStyle(fontSize: 16)),
                    Text('${weatherData.wind.speed} m/s', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      // ---- KẾT THÚC PHẦN CẬP NHẬT ----
    } else if (state is WeatherLoadFailure) {
      return Center(
        child: Text(
          'Lỗi: ${state.message}',
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
  @override
  void dispose() {
    _cityController.dispose();
    // BlocProvider tự động dispose BLoC
    super.dispose();
  }
}