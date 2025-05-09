import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/forecast_data.dart';

class HourlyForecastDisplay extends StatelessWidget {
  final ForecastData forecastData;
  final DateTime? selectedDate;

  const HourlyForecastDisplay({
    super.key,
    required this.forecastData,
    this.selectedDate,
  });

  List<ListElement> _getHourlyForecasts() {
    if (selectedDate != null) {
      return forecastData.list.where((item) {
        return item.dtTxt != null &&
            item.dtTxt!.year == selectedDate!.year &&
            item.dtTxt!.month == selectedDate!.month &&
            item.dtTxt!.day == selectedDate!.day;
      }).toList();
    } else {
      return forecastData.list.take(8).toList();
    }
  }

  String _getTitle() {
    if (selectedDate != null) {
      final formattedDate = '${selectedDate!.day.toString().padLeft(2,'0')}/${selectedDate!.month.toString().padLeft(2,'0')}';
      return 'Dự báo giờ cho ngày $formattedDate';
    } else {
      return 'Dự báo 24 giờ tới';
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _getHourlyForecasts();

    if (displayList.isEmpty) {
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
        child: const Center(
          child: Text(
            "Không có dữ liệu dự báo theo giờ cho ngày này.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                final itemTime = item.dtTxt;
                final itemTemp = item.main.temp;
                final itemWeather = item.weather.firstOrNull;
                final WeatherIconEnum? itemIconEnum = itemWeather?.icon;
                final String? itemIconCode = itemIconEnum != null ? weatherIconEnumValues.reverse[itemIconEnum] : null;
                final itemIconUrl = itemIconCode != null
                    ? '${ApiConstants.weatherIconBaseUrl}$itemIconCode${ApiConstants.weatherIconSuffix}'
                    : null;

                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        itemTime != null ? '${itemTime.hour.toString().padLeft(2, '0')}:00' : '--',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      if (itemIconUrl != null)
                        Image.network(
                          itemIconUrl,
                          width: 50,
                          height: 50,
                          errorBuilder: (c, e, s) => const SizedBox(width: 50),
                        )
                      else
                        const SizedBox(width: 50, height: 50),
                      Text(
                        '${itemTemp.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        itemWeather?.description?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
