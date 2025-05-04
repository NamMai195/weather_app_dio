import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';

class CurrentWeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final String displayedCityName;

  const CurrentWeatherDisplay({
    super.key,
    required this.weatherData,
    required this.displayedCityName,
  });

  @override
  Widget build(BuildContext context) {
    final weatherInfo = weatherData.weather.isNotEmpty ? weatherData.weather[0] : null;
    final String? iconString = weatherInfo?.icon;
    final iconUrl = iconString != null ? 'https://openweathermap.org/img/wn/$iconString@2x.png' : null;
    final description = weatherInfo?.description ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          displayedCityName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (iconUrl != null)
          Image.network(
            iconUrl,
            width: 100, height: 100,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, size: 50),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(width: 100, height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)));
            },
          )
        else
          const SizedBox(height: 100, width: 100), // Placeholder nếu không có icon
        Text(
          description,
          style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
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
            _buildInfoColumn('Độ ẩm', '${weatherData.main.humidity}%'),
            _buildInfoColumn('Gió', '${weatherData.wind.speed} m/s'),
          ],
        ),
      ],
    );
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
}