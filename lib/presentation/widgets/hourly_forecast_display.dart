import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/forecast_data.dart';

class HourlyForecastDisplay extends StatelessWidget {
  final List<ListElement> hourlyForecasts;
  final String title;

  const HourlyForecastDisplay({
    super.key,
    required this.hourlyForecasts,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final displayList = hourlyForecasts;

    if (displayList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("Không có dữ liệu dự báo theo giờ cho ngày này.")),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final item = displayList[index];
                final itemTime = item.dtTxt;
                final itemTemp = item.main.temp;
                final itemWeather = item.weather.firstOrNull;
                final WeatherIconEnum? itemIconEnum = itemWeather?.icon;
                final String? itemIconCode = itemIconEnum != null ? weatherIconEnumValues.reverse[itemIconEnum] : null;
                final itemIconUrl = itemIconCode != null ? '${ApiConstants.weatherIconBaseUrl}$itemIconCode${ApiConstants.weatherIconSuffix}' : null;

                return Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text( itemTime != null ? '${itemTime.hour.toString().padLeft(2, '0')}' : '--', style: const TextStyle(fontWeight: FontWeight.bold),),
                        if (itemIconUrl != null) Image.network(itemIconUrl, width: 40, height: 40, errorBuilder: (c, e, s) => const SizedBox(width: 40)) else const SizedBox(width: 40, height: 40),
                        Text('${itemTemp.toStringAsFixed(0)}°'),
                      ]
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
