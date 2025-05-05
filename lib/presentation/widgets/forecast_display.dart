import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import '../../domain/entities/forecast_data.dart';

class DailySummary extends Equatable {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String? iconCode;
  final String? description;

  const DailySummary({
    required this.date, required this.minTemp, required this.maxTemp,
    this.iconCode, this.description,
  });
  @override List<Object?> get props => [date, minTemp, maxTemp, iconCode, description];
}

class ForecastDisplay extends StatelessWidget {
  final ForecastData forecastData;

  const ForecastDisplay({
    super.key,
    required this.forecastData,
  });
  Map<DateTime, List<ListElement>> _groupForecastsByDay(List<ListElement> forecastList) {
    final Map<DateTime, List<ListElement>> groupedByDay = {};
    if (forecastList.isEmpty) return groupedByDay;

    final today = DateTime.now();
    final todayDateKey = DateTime(today.year, today.month, today.day);

    for (var item in forecastList) {
      if (item.dtTxt != null) {
        final dateKey = DateTime(item.dtTxt!.year, item.dtTxt!.month, item.dtTxt!.day);
        // Chỉ lấy các ngày sau ngày hôm nay
        if (dateKey.isAfter(todayDateKey)) {
          if (groupedByDay.containsKey(dateKey)) {
            groupedByDay[dateKey]!.add(item);
          } else {
            groupedByDay[dateKey] = [item];
          }
        }
      }
    }
    return groupedByDay;
  }
  DailySummary _calculateDailySummary(DateTime date, List<ListElement> itemsForDay) {
    double minTemp = itemsForDay[0].main.tempMin;
    double maxTemp = itemsForDay[0].main.tempMax;

    // Tìm item đại diện (ví dụ: giữa ngày)
    final midDayItem = itemsForDay.firstWhere(
            (item) => item.dtTxt != null && item.dtTxt!.hour >= 11 && item.dtTxt!.hour < 15,
        orElse: () => itemsForDay[itemsForDay.length ~/ 2]);
    final WeatherIconEnum? representativeIconEnum = midDayItem.weather.firstOrNull?.icon;
    final String? representativeIconCode = representativeIconEnum != null ? weatherIconEnumValues.reverse[representativeIconEnum] : null;
    final Description? representativeDescEnum = midDayItem.weather.firstOrNull?.description;
    final String? representativeDesc = representativeDescEnum != null ? descriptionValues.reverse[representativeDescEnum] : null;

    // Tính Min/Max chuẩn hơn
    for (var item in itemsForDay) {
      if (item.main.tempMin < minTemp) minTemp = item.main.tempMin;
      if (item.main.tempMax > maxTemp) maxTemp = item.main.tempMax;
    }

    return DailySummary(
      date: date, minTemp: minTemp, maxTemp: maxTemp,
      iconCode: representativeIconCode, description: representativeDesc,
    );
  }
  List<DailySummary> _processForecastData(ForecastData data) {
    if (data.list.isEmpty) return [];

    final groupedData = _groupForecastsByDay(data.list);

    final dailySummaries = groupedData.entries.map((entry) {
      return _calculateDailySummary(entry.key, entry.value);
    }).toList();

    dailySummaries.sort((a, b) => a.date.compareTo(b.date));

    return dailySummaries;
  }

  @override
  Widget build(BuildContext context) {
    final List<DailySummary> dailySummaries = _processForecastData(forecastData);

    return Column(
      children: [
        const Text(
          'Dự báo 5 ngày tới',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (dailySummaries.isEmpty)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('Không có dữ liệu dự báo theo ngày.'))
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailySummaries.length > 5 ? 5 : dailySummaries.length,
            itemBuilder: (context, index) {
              final summary = dailySummaries[index];
              final dayOfWeek = ['Th 2','Th 3','Th 4','Th 5','Th 6','Th 7','CN'][summary.date.weekday - 1];
              final dateString = '${summary.date.day.toString().padLeft(2,'0')}/${summary.date.month.toString().padLeft(2,'0')}';
              final iconUrl = summary.iconCode != null
                  ? '${ApiConstants.weatherIconBaseUrl}${summary.iconCode}${ApiConstants.weatherIconSuffix}' // Dùng hằng số
                  : null;
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
  }
}