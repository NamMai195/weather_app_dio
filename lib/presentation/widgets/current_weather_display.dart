import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import '../../domain/entities/weather.dart';

class CurrentWeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final String cityName;

  const CurrentWeatherDisplay({
    super.key,
    required this.weatherData,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = weatherData.weather.isNotEmpty ? weatherData.weather[0] : null;
    final String? iconString = weatherInfo?.icon;
    final iconUrl = iconString != null
        ? '${ApiConstants.weatherIconBaseUrl}$iconString${ApiConstants.weatherIconSuffix}' 
        : null;
    final description = weatherInfo?.description ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            cityName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          if (iconUrl != null)
            Hero(
              tag: 'weather_icon_$cityName',
              child: Image.network(
                iconUrl,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.white70,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(height: 120, width: 120),
          const SizedBox(height: 15),
          Text(
            description.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Text(
            '${weatherData.main.temp.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn(
                  Icons.water_drop,
                  'Độ ẩm',
                  '${weatherData.main.humidity}%',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildInfoColumn(
                  Icons.air,
                  'Gió',
                  '${weatherData.wind.speed} m/s',
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                _buildInfoColumn(
                  Icons.thermostat,
                  'Cảm giác',
                  '${weatherData.main.feelsLike.toStringAsFixed(1)}°C',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}