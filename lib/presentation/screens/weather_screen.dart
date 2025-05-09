import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/domain/entities/forecast_data.dart';
import 'package:weather_app/locator.dart';
import 'package:weather_app/presentation/widgets/hourly_forecast_display.dart';
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

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  LocationSuggestion? _selectedSuggestion;
  Timer? _debounceTimer;
  List<LocationSuggestion> _currentSuggestions = [];
  bool _isLoadingSuggestions = false;
  DateTime? _selectedForecastDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDaySelected(DateTime selectedDate) {
    setState(() {
      if (_selectedForecastDate == selectedDate) {
        _selectedForecastDate = null;
      } else {
        _selectedForecastDate = selectedDate;
      }
      print('Selected forecast date updated: $_selectedForecastDate');
    });
  }

  LinearGradient _getBackgroundGradient(WeatherState state) {
    if (state is WeatherLoadSuccess) {
      final weatherCode = state.weatherData.weather.first.id;
      if (weatherCode >= 200 && weatherCode < 300) {
        // Thunderstorm
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        );
      } else if (weatherCode >= 300 && weatherCode < 400) {
        // Drizzle/Rain
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
        );
      } else if (weatherCode >= 500 && weatherCode < 600) {
        // Rain
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF2980B9)],
        );
      } else if (weatherCode >= 600 && weatherCode < 700) {
        // Snow
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFFBDC3C7)],
        );
      } else if (weatherCode >= 700 && weatherCode < 800) {
        // Atmosphere (fog, mist, etc.)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF95A5A6)],
        );
      } else if (weatherCode == 800) {
        // Clear
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
        );
      } else if (weatherCode > 800) {
        // Clouds
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF7F8C8D)],
        );
      }
    }
    // Default gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<WeatherBloc>(),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: _getBackgroundGradient(state),
              ),
              child: SafeArea(
                child: GestureDetector(
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
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(height: 20),
                              _buildSearchField(context, state),
                              const SizedBox(height: 20),
                              if (state is WeatherLoadSuccess) ...[
                                CurrentWeatherDisplay(
                                  weatherData: state.weatherData,
                                  cityName: state.displayedCityName,
                                ),
                                const SizedBox(height: 20),
                                ForecastDisplay(
                                  forecastData: state.forecastData,
                                  onDaySelected: _handleDaySelected,
                                  selectedDate: _selectedForecastDate,
                                ),
                                const SizedBox(height: 20),
                                HourlyForecastDisplay(
                                  forecastData: state.forecastData,
                                  selectedDate: _selectedForecastDate,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, WeatherState state) {
    bool isLoading = state is WeatherLoadInProgress;
    bool inputIsValid = (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) ||
        (_selectedSuggestion == null && _cityController.text.trim().isNotEmpty);
    bool allowNewSearchFromState = true;
    if (state is WeatherLoadSuccess) {
      allowNewSearchFromState = state.allowNewSearch;
    }
    bool canPressButtonOrSubmit = !isLoading && inputIsValid && allowNewSearchFromState;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Autocomplete<LocationSuggestion>(
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nhập hoặc chọn thành phố',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'Ví dụ: Hanoi, Lon...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
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
          return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _isLoadingSuggestions && options.isEmpty && _cityController.text.isNotEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                : options.isEmpty && _cityController.text.isNotEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Không tìm thấy gợi ý.")))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final LocationSuggestion option = options.elementAt(index);
                        return InkWell(
                          onTap: () { onSelected(option); },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              option.displayName,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final suggestions = await locator<WeatherRepository>().getCitySuggestions(query);
      if (mounted) {
        setState(() {
          _currentSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  void _performSearch(BuildContext context) {
    if (_selectedSuggestion != null && _selectedSuggestion!.lat != null && _selectedSuggestion!.lon != null) {
      context.read<WeatherBloc>().add(WeatherRequestedCoords(
        lat: _selectedSuggestion!.lat!,
        lon: _selectedSuggestion!.lon!,
        selectedName: _selectedSuggestion!.name,
      ));
    } else {
      context.read<WeatherBloc>().add(WeatherRequested(_cityController.text.trim()));
    }
  }
}
