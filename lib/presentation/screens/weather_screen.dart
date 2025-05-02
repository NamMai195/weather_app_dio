import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/locator.dart';
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

class DailySummary extends Equatable{
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String? iconCode;
  final String? description;

  const DailySummary({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    this.iconCode,
    this.description,
  });

  @override
  List<Object?> get props => [date, minTemp, maxTemp, iconCode, description];
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
                  ( (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) || // Có suggestion hợp lệ
                      (_selectedSuggestion == null && _cityController.text.trim().isNotEmpty) ); // Hoặc không có suggestion nhưng có text
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
                            _cityController.text = selection.name; // Hoặc selection.displayName
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
                              // Đồng bộ controller lần cuối trước khi submit
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
      // Lấy dữ liệu
      final currentWeatherData = state.weatherData;
      final forecastData = state.forecastData;
      final currentWeatherInfo = currentWeatherData.weather.isNotEmpty ? currentWeatherData.weather[0] : null;
      final String? currentIconString = currentWeatherInfo?.icon; // Icon hiện tại là String
      final currentIconUrl = currentIconString != null ? 'https://openweathermap.org/img/wn/$currentIconString@2x.png' : null;

      // Xử lý forecast data thành daily summary
      final List<DailySummary> dailySummaries = _processForecastData(forecastData);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Phần hiển thị thời tiết hiện tại ---
          Text(state.displayedCityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (currentIconUrl != null)
            Image.network(
              currentIconUrl, width: 100, height: 100,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, size: 50), // Dùng Icon của Material
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(width: 100, height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
              },
            ),
          Text(
            currentWeatherInfo?.description ?? 'N/A',
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text('${currentWeatherData.main.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildInfoColumn('Độ ẩm', '${currentWeatherData.main.humidity}%'),
            _buildInfoColumn('Gió', '${currentWeatherData.wind.speed} m/s'),
          ]),
          // --- Kết thúc phần hiển thị thời tiết hiện tại ---

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          // --- PHẦN HIỂN THỊ DỰ BÁO THEO NGÀY ---
          const Text('Dự báo 5 ngày tới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (dailySummaries.isEmpty)
            const Padding( padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: Text('Không có dữ liệu dự báo theo ngày.')))
          else
            ListView.builder(
              shrinkWrap: true, // Quan trọng khi ListView trong Column
              physics: const NeverScrollableScrollPhysics(), // Không cho cuộn riêng
              itemCount: dailySummaries.length > 5 ? 5 : dailySummaries.length, // Giới hạn 5 ngày
              itemBuilder: (context, index) {
                final summary = dailySummaries[index];
                // Định dạng ngày/thứ (không dùng intl)
                final dayOfWeek = ['Th 2','Th 3','Th 4','Th 5','Th 6','Th 7','CN'][summary.date.weekday-1];
                final dateString = '${summary.date.day.toString().padLeft(2,'0')}/${summary.date.month.toString().padLeft(2,'0')}';
                final iconUrl = summary.iconCode != null ? 'https://openweathermap.org/img/wn/${summary.iconCode}@2x.png' : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 65, child: Column(children: [ Text(dayOfWeek, style: const TextStyle(fontWeight: FontWeight.bold)), Text(dateString, style: const TextStyle(color: Colors.grey)) ])),
                      if (iconUrl != null)
                        Image.network(iconUrl, width: 40, height: 40, errorBuilder: (c, e, s) => const SizedBox(width: 40))
                      else
                        const SizedBox(width: 40, height: 40),
                      Row( children: [
                        Text('${summary.maxTemp.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('${summary.minTemp.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ]
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );

    } else if (state is WeatherLoadFailure) {
      return Center(
        child: Text( 'Lỗi: ${state.message}', style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center, ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<DailySummary> _processForecastData(ForecastData forecastData) {
    final List<DailySummary> dailySummaries = [];
    if (forecastData.list.isEmpty) return dailySummaries;

    final Map<DateTime, List<ListElement>> groupedByDay = {};
    final today = DateTime.now();
    final todayDateKey = DateTime(today.year, today.month, today.day);

    for (var item in forecastData.list) {
      if (item.dtTxt != null) {
        final dateKey = DateTime(item.dtTxt!.year, item.dtTxt!.month, item.dtTxt!.day);
        if (dateKey.isAfter(todayDateKey)) {
          if (groupedByDay.containsKey(dateKey)) { groupedByDay[dateKey]!.add(item); }
          else { groupedByDay[dateKey] = [item]; }
        }
      }
    }

    groupedByDay.forEach((date, itemsForDay) {
      if (itemsForDay.isNotEmpty) {
        double minTemp = itemsForDay[0].main.tempMin;
        double maxTemp = itemsForDay[0].main.tempMax;

        final midDayItem = itemsForDay.firstWhere(
                (item) => item.dtTxt != null && item.dtTxt!.hour >= 11 && item.dtTxt!.hour < 15,
            orElse: () => itemsForDay[itemsForDay.length ~/ 2]);
        final WeatherIconEnum? representativeIconEnum = midDayItem.weather.firstOrNull?.icon;
        final String? representativeIconCode = representativeIconEnum != null ? weatherIconEnumValues.reverse[representativeIconEnum] : null;
        final Description? representativeDescEnum = midDayItem.weather.firstOrNull?.description;
        final String? representativeDesc = representativeDescEnum != null ? descriptionValues.reverse[representativeDescEnum] : null; // Lấy lại string gốc tv

        for (var item in itemsForDay) {
          if (item.main.tempMin < minTemp) minTemp = item.main.tempMin;
          if (item.main.tempMax > maxTemp) maxTemp = item.main.tempMax;
        }
        dailySummaries.add(DailySummary(
          date: date, minTemp: minTemp, maxTemp: maxTemp,
          iconCode: representativeIconCode, description: representativeDesc,
        ));
      }
    });
    dailySummaries.sort((a, b) => a.date.compareTo(b.date));
    return dailySummaries;
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

