// lib/presentation/widgets/forecast_display.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
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
  final Function(DateTime)? onDaySelected;
  final DateTime? selectedDate;

  const ForecastDisplay({
    super.key,
    required this.forecastData,
    this.onDaySelected,
    this.selectedDate,
  });

  List<DailySummary> _processForecastData(ForecastData data) {
    final List<DailySummary> dailySummaries = [];
    if (data.list.isEmpty) return dailySummaries;
    final Map<DateTime, List<ListElement>> groupedByDay = _groupForecastsByDay(data.list);
    groupedByDay.forEach((date, itemsForDay) {
      if (itemsForDay.isNotEmpty) {
        dailySummaries.add(_calculateDailySummary(date, itemsForDay));
      }
    });
    dailySummaries.sort((a, b) => a.date.compareTo(b.date));
    return dailySummaries;
  }

  Map<DateTime, List<ListElement>> _groupForecastsByDay(List<ListElement> forecastList) {
    final Map<DateTime, List<ListElement>> groupedByDay = {};
    if (forecastList.isEmpty) return groupedByDay;

    final today = DateTime.now();
    final todayDateKey = DateTime(today.year, today.month, today.day);

    for (var item in forecastList) {
      if (item.dtTxt != null) {
        final dateKey = DateTime(item.dtTxt!.year, item.dtTxt!.month, item.dtTxt!.day);
        if (!dateKey.isBefore(todayDateKey)) {
          if (groupedByDay.containsKey(dateKey)) { groupedByDay[dateKey]!.add(item); }
          else { groupedByDay[dateKey] = [item]; }
        }
      }
    }
    return groupedByDay;
  }

  DailySummary _calculateDailySummary(DateTime date, List<ListElement> itemsForDay) {
    double minTemp = itemsForDay[0].main.tempMin;
    double maxTemp = itemsForDay[0].main.tempMax;
    final midDayItem = itemsForDay.firstWhere( (item) => item.dtTxt != null && item.dtTxt!.hour >= 11 && item.dtTxt!.hour < 15, orElse: () => itemsForDay[itemsForDay.length ~/ 2]);
    final WeatherIconEnum? representativeIconEnum = midDayItem.weather.firstOrNull?.icon;
    final String? representativeIconCode = (representativeIconEnum != null && representativeIconEnum != WeatherIconEnum.UNKNOWN) ? weatherIconEnumValues.reverse[representativeIconEnum] : null;
    final Description? representativeDescEnum = midDayItem.weather.firstOrNull?.description;
    final String? representativeDesc = (representativeDescEnum != null && representativeDescEnum != Description.UNKNOWN) ? descriptionValues.reverse[representativeDescEnum] : null;
    for (var item in itemsForDay) { if (item.main.tempMin < minTemp) minTemp = item.main.tempMin; if (item.main.tempMax > maxTemp) maxTemp = item.main.tempMax; }
    return DailySummary( date: date, minTemp: minTemp, maxTemp: maxTemp, iconCode: representativeIconCode, description: representativeDesc, );
  }


  @override
  Widget build(BuildContext context) {
    final List<DailySummary> dailySummaries = _processForecastData(forecastData);
    final today = DateTime.now();
    final todayDateKey = DateTime(today.year, today.month, today.day);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          const Text( AppConstants.forecastTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold) ),
          const SizedBox(height: 10),
          if (dailySummaries.isEmpty)
            const Padding( padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: Text(AppConstants.noForecastData)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailySummaries.length > 5 ? 5 : dailySummaries.length,
              itemBuilder: (context, index) {
                final summary = dailySummaries[index];
                final bool isSelected = selectedDate == summary.date;
                String displayDay;
                if (summary.date == todayDateKey) {
                  displayDay = "Hôm nay";
                } else {
                  displayDay = ['Th 2','Th 3','Th 4','Th 5','Th 6','Th 7','CN'][summary.date.weekday - 1];
                }
                final dateString = '${summary.date.day.toString().padLeft(2,'0')}/${summary.date.month.toString().padLeft(2,'0')}';
                final iconUrl = summary.iconCode != null ? '${ApiConstants.weatherIconBaseUrl}${summary.iconCode}${ApiConstants.weatherIconSuffix}' : null;

                return InkWell(
                  onTap: () { onDaySelected?.call(summary.date); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    margin: const EdgeInsets.symmetric(vertical: 2.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 65, child: Column(children: [ Text(displayDay, style: const TextStyle(fontWeight: FontWeight.bold)), Text(dateString, style: const TextStyle(color: Colors.grey)) ])),
                        if (iconUrl != null) Image.network(iconUrl, width: 40, height: 40, errorBuilder: (c, e, s) => const SizedBox(width: 40)) else const SizedBox(width: 40, height: 40),
                        Row( children: [ Text('${summary.maxTemp.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text('${summary.minTemp.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 16, color: Colors.grey)), ] ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
