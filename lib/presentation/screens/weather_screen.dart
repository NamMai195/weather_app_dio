import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/locator.dart';

import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';

import '../../domain/entities/location_suggestion.dart';
import '../../domain/repositories/weather_repository.dart';





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
      create: (context) => locator<WeatherBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            bool isLoading = state is WeatherLoadInProgress;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Autocomplete<LocationSuggestion>(
                    displayStringForOption: (LocationSuggestion option) => option.name,
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      final String query = textEditingValue.text;
                      if (query.trim().isEmpty) {
                        return const Iterable<LocationSuggestion>.empty();
                      }
                      // TODO: Refactor using proper Dependency Injection (e.g., get_it) later.
                      final WeatherRepository repository =locator<WeatherRepository>();
                      // TODO: Implement debouncing to avoid excessive API calls.
                      final suggestions = await repository.getCitySuggestions(query);
                      return suggestions;
                    },
                    onSelected: (LocationSuggestion selection) {
                      _cityController.text = selection.name;
                      FocusScope.of(context).unfocus();
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Nhập hoặc chọn thành phố',
                          hintText: 'Ví dụ: Hanoi, Lon...',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !isLoading,
                        onChanged: (String text) {
                          _cityController.text = text;
                        },
                        onSubmitted: (_) {
                          _cityController.text = fieldTextEditingController.text;
                          final cityName = _cityController.text.trim();
                          if (cityName.isNotEmpty && !isLoading) {
                            context.read<WeatherBloc>().add(WeatherRequested(cityName));
                          }
                        },
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<LocationSuggestion> onSelected,
                        Iterable<LocationSuggestion> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final LocationSuggestion option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option.displayName),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ), // Kết thúc Autocomplete

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: (isLoading || _cityController.text.trim().isEmpty)
                        ? null // Disable khi đang load hoặc ô nhập rỗng
                        : () {
                      final cityName = _cityController.text.trim();
                      // Gửi sự kiện với tên thành phố từ controller chính
                      context.read<WeatherBloc>().add(WeatherRequested(cityName));
                    },
                    child: const Text('Xem Thời Tiết'),
                  ),
                  const SizedBox(height: 30),

                  // Phần hiển thị kết quả thời tiết
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              '${weatherData.main.temp.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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