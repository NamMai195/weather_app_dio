import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/locator.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/repositories/weather_repository.dart';
import '../widgets/current_weather_display.dart';
import '../widgets/forecast_display.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  LocationSuggestion? _selectedSuggestion;
  Timer? _debounceTimer;
  List<LocationSuggestion> _currentSuggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<WeatherBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text(AppConstants.appTitle)), // Dùng hằng số
          body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocListener<WeatherBloc, WeatherState>(
  listener: (context, state) {
    if (state is WeatherLoadFailure) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text(state.message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
    }
  },
  child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              bool isLoading = state is WeatherLoadInProgress;

              bool inputIsValid = (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) ||
                  (_selectedSuggestion == null && _cityController.text.trim().isNotEmpty);

              bool allowNewSearchFromState = true;
              if (state is WeatherLoadSuccess) {
                allowNewSearchFromState = state.allowNewSearch;
              }

              bool canPressButtonOrSubmit = !isLoading && inputIsValid && allowNewSearchFromState;


              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Autocomplete<LocationSuggestion>(
                        displayStringForOption: (option) => option.name,
                        optionsBuilder: (textEditingValue) {
                          _debounceTimer?.cancel();
                          final String query = textEditingValue.text;

                          if (query.trim().isEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if(mounted && (_currentSuggestions.isNotEmpty || _isLoadingSuggestions)) {
                                setState(() {
                                  _currentSuggestions = [];
                                  _isLoadingSuggestions = false;
                                });
                              }
                            });
                            return _currentSuggestions;
                          } else {
                            if (!_isLoadingSuggestions && mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if(mounted) { setState(() { _isLoadingSuggestions = true; }); }
                              });
                            }
                            _debounceTimer = Timer(Duration(milliseconds: AppConstants.debounceDurationMs), () {
                              if (mounted && _cityController.text.trim() == query.trim()) {
                                _fetchSuggestions(query);
                              } else if (mounted && _isLoadingSuggestions) {
                                setState(() { _isLoadingSuggestions = false; });
                              } else if (mounted && query.trim().isEmpty){
                                setState(() { _currentSuggestions = []; _isLoadingSuggestions = false; });
                              }
                            });
                            return _currentSuggestions;
                          }
                        },
                        onSelected: (selection) {
                          setState(() {
                            _selectedSuggestion = selection;
                            _cityController.text = selection.name;
                          });
                          FocusScope.of(context).unfocus();
                          context.read<WeatherBloc>().add(UserInputChanged());
                        },
                        fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
                          if (_selectedSuggestion == null && _cityController.text != fieldController.text) {
                            fieldController.text = _cityController.text;
                          } else if (_selectedSuggestion != null && fieldController.text != _selectedSuggestion!.name) {
                            fieldController.text = _selectedSuggestion!.name;
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
                              bool selectionWasCleared = false;
                              _cityController.text = text;
                              if (_selectedSuggestion != null) {
                                setState(() { _selectedSuggestion = null; });
                                selectionWasCleared = true;
                              }
                              if (text.isNotEmpty || selectionWasCleared) {
                                context.read<WeatherBloc>().add(UserInputChanged());
                              }
                            },
                            onSubmitted: (_) {
                              _cityController.text = fieldController.text;
                              if (canPressButtonOrSubmit) {
                                _performSearch(context);
                              }
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          Widget listContent;
                          if (_isLoadingSuggestions && options.isEmpty && _cityController.text.isNotEmpty) {
                            listContent = const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2)));
                          } else if (!_isLoadingSuggestions && options.isEmpty && _cityController.text.isNotEmpty) {
                            listContent = const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Không tìm thấy gợi ý.")));
                          } else {
                            listContent = ListView.builder(
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
                            );
                          }
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 250),
                                child: listContent,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: canPressButtonOrSubmit ? () => _performSearch(context) : null,
                        child: const Text('Xem Thời Tiết'),
                      ),
                      const SizedBox(height: 30),

                      _buildWeatherContent(context, state),
                    ],
                  ),
                ),
              );
            },
          ),
),
        ),
      ),
    );
  }

  void _performSearch(BuildContext context) {
    if (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) {
      context.read<WeatherBloc>().add(WeatherRequestedCoords(lat: _selectedSuggestion!.lat!, lon: _selectedSuggestion!.lon!, selectedName: _selectedSuggestion!.name));
    } else if (_cityController.text.trim().isNotEmpty) {
      context.read<WeatherBloc>().add(WeatherRequested(_cityController.text.trim()));
    }
  }

  Widget _buildWeatherContent(BuildContext context, WeatherState state) {
    if (state is WeatherInitial) {
      // Hiển thị thông báo ban đầu
      return const Center( child: Text( 'Nhập tên thành phố và nhấn nút để xem thời tiết.', style: TextStyle(fontSize: 16), textAlign: TextAlign.center, ), );
    } else if (state is WeatherLoadInProgress) {
      // Hiển thị loading
      return const Center(heightFactor: 5, child: CircularProgressIndicator());
    } else if (state is WeatherLoadSuccess) {
      // Hiển thị kết quả thành công (dùng widget con)
      return Column(
        children: [
          CurrentWeatherDisplay(weatherData: state.weatherData, displayedCityName: state.displayedCityName),
          const SizedBox(height: 30), const Divider(), const SizedBox(height: 10),
          ForecastDisplay(forecastData: state.forecastData),
        ],
      );
    } else if (state is WeatherLoadFailure) {
      return const Center( child: Text( 'Nhập tên thành phố và nhấn nút để xem thời tiết.', style: TextStyle(fontSize: 16), textAlign: TextAlign.center, ), ); // Hoặc quay về trạng thái ban đầu
    } else {
      // State không xác định
      return const SizedBox.shrink();
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (mounted && !_isLoadingSuggestions) { setState(() { _isLoadingSuggestions = true; }); }
    print('Fetching suggestions for query: $query');
    try {
      final repository = locator<WeatherRepository>();
      final suggestions = await repository.getCitySuggestions(query);
      if (mounted) {
        setState(() { _currentSuggestions = suggestions; _isLoadingSuggestions = false; });
        print('Suggestions updated: ${_currentSuggestions.length} items');
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
      if (mounted) { setState(() { _currentSuggestions = []; _isLoadingSuggestions = false; }); }
    }
  }

}
