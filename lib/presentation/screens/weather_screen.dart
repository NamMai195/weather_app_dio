// lib/presentation/screens/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc library
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
      create: (context) => WeatherBloc(), // Tạo instance của WeatherBloc
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
  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      // Trạng thái ban đầu
      return const Center(
        child: Text(
          'Nhập tên thành phố và nhấn nút để xem thời tiết.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (state is WeatherLoadInProgress) {
      // Trạng thái đang tải -> Hiển thị vòng xoay loading
      return const Center(child: CircularProgressIndicator());
    } else if (state is WeatherLoadSuccess) {
      // Trạng thái thành công -> Hiển thị kết quả (Tạm thời chỉ là text)
      // Sau này sẽ thay bằng Widget hiển thị data thời tiết thật
      return const Center(
        child: Text(
          'Tải dữ liệu thành công! (Sẽ hiển thị data ở đây)',
          style: TextStyle(fontSize: 16, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      );
    } else if (state is WeatherLoadFailure) {
      // Trạng thái lỗi -> Hiển thị thông báo lỗi
      return Center(
        child: Text(
          'Lỗi: ${state.message}', // Hiển thị thông báo lỗi từ state
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Trường hợp state không xác định (không nên xảy ra)
      return const SizedBox.shrink(); // Không hiển thị gì cả
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    // BlocProvider tự động dispose BLoC
    super.dispose();
  }
}