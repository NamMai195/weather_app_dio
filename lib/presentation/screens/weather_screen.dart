import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/locator.dart';
import 'package:weather_app/presentation/widgets/current_weather_display.dart';
import 'package:weather_app/presentation/widgets/forecast_display.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/entities/forecast_data.dart';
import '../../domain/repositories/weather_repository.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}




class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  LocationSuggestion? _selectedSuggestion;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<WeatherBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Weather App')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              bool isLoading = state is WeatherLoadInProgress;
              bool canSearch = !isLoading &&
                  ( (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) ||
                      (_selectedSuggestion == null && _cityController.text.trim().isNotEmpty) );
              return SingleChildScrollView(
                child: Padding(
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
                          final WeatherRepository repository = locator<WeatherRepository>();
                          // TODO: Implement debouncing.
                          final suggestions = await repository.getCitySuggestions(query);
                          return suggestions;
                        },
                        onSelected: (LocationSuggestion selection) {
                          setState(() {
                            _selectedSuggestion = selection;
                            _cityController.text = selection.name;
                          });
                          FocusScope.of(context).unfocus();
                        },
                        fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
                          if (_selectedSuggestion == null && _cityController.text != fieldController.text) {
                            fieldController.text = _cityController.text;
                          }
                          return TextField(
                            controller: fieldController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Nhập hoặc chọn thành phố',
                              hintText: 'Ví dụ: Hanoi, Lon...',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !isLoading,
                            onChanged: (text) {
                              _cityController.text = text;
                              if (_selectedSuggestion != null) {
                                setState(() {
                                  _selectedSuggestion = null;
                                });
                              }
                            },
                            onSubmitted: (_) {
                              _cityController.text = fieldController.text;
                              // Gọi hàm xử lý submit chung
                              _performSearch(context);
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
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
                                      onTap: () { onSelected(option); },
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
                        onPressed: canSearch ? () => _performSearch(context) : null,
                        child: const Text('Xem Thời Tiết'),
                      ),
                      const SizedBox(height: 30),

                      // Phần hiển thị kết quả thời tiết và dự báo
                      _buildWeatherContent(context, state),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  void _performSearch(BuildContext context) {
    // Ưu tiên dùng tọa độ từ suggestion đã chọn
    if (_selectedSuggestion != null &&
        _selectedSuggestion!.lat != null &&
        _selectedSuggestion!.lon != null)
    {
      print("Dispatching WeatherRequestedByCoords: lat=${_selectedSuggestion!.lat}, lon=${_selectedSuggestion!.lon}");
      context.read<WeatherBloc>().add(WeatherRequestedCoords(
        lat: _selectedSuggestion!.lat!,
        lon: _selectedSuggestion!.lon!,
        selectedName: _selectedSuggestion!.name,
      ));
    }
    // Nếu không có suggestion hoặc suggestion thiếu tọa độ, dùng city name
    else if (_cityController.text.trim().isNotEmpty)
    {
      final cityName = _cityController.text.trim();
      print("Dispatching WeatherRequested: city=$cityName");
      context.read<WeatherBloc>().add(WeatherRequested(cityName));
    }
  }

  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      return const Center( child: Text( 'Nhập tên thành phố và nhấn nút để xem thời tiết.', style: TextStyle(fontSize: 16), textAlign: TextAlign.center, ), );
    } else if (state is WeatherLoadInProgress) {
      return const Center(heightFactor: 5, child: CircularProgressIndicator());
    } else if (state is WeatherLoadSuccess) {
      return Column(
        children: [
          // Widget hiển thị thời tiết hiện tại
          CurrentWeatherDisplay(
            weatherData: state.weatherData,
            displayedCityName: state.displayedCityName, // Truyền tên hiển thị
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          // Widget hiển thị dự báo
          ForecastDisplay(forecastData: state.forecastData),
        ],
      );
    } else if (state is WeatherLoadFailure) {
      return Center( child: Text( 'Lỗi: ${state.message}', style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center, ), );
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

