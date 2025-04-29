import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart';
import '../bloc/weather_bloc.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => WeatherBloc(
            weatherRepository: WeatherRepositoryImpl(
              remoteDataSource: WeatherRemoteDataSourceImpl(
                dio: Dio(),
              ),
            ),
          ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập tên thành phố',
                      hintText: 'Ví dụ: Hanoi',
                      border: OutlineInputBorder(),
                    ),
                    enabled: state is! WeatherLoadInProgress,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                        (state is WeatherLoadInProgress)
                            ? null
                            : () {
                              final cityName = _cityController.text;
                              if (cityName.isNotEmpty) {
                                context.read<WeatherBloc>().add(
                                  WeatherRequested(cityName),
                                );
                              }
                            },
                    child: const Text('Xem Thời Tiết'),
                  ),
                  const SizedBox(height: 30),

                  _buildWeatherContent(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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
      final weatherData = state.weatherData;
      final weatherInfo =
          weatherData.weather.isNotEmpty ? weatherData.weather[0] : null;
      final iconCode = weatherInfo?.icon;
      final iconUrl =
          iconCode != null
              ? 'https://openweathermap.org/img/wn/$iconCode@2x.png'
              : null;

      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Text(
              weatherData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (iconUrl != null)
              Image.network(
                iconUrl,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, size: 50);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),

            if (weatherInfo != null)
              Text(
                weatherInfo.description,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 20),

            Text(
              '${weatherData.main.temp.toStringAsFixed(1)}°C', // Nhiệt độ (làm tròn 1 chữ số thập phân)
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Độ ẩm', style: TextStyle(fontSize: 16)),
                    Text(
                      '${weatherData.main.humidity}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Gió', style: TextStyle(fontSize: 16)),
                    Text(
                      '${weatherData.wind.speed} m/s',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
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
    super.dispose();
  }
}
