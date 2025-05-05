import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart'; // Import constants
import '../../domain/entities/forecast_data.dart'; // Import ForecastData và ListElement

class HourlyForecastDisplay extends StatelessWidget {
  final List<ListElement> hourlyForecasts;

  const HourlyForecastDisplay({
    super.key,
    required this.hourlyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy khoảng 8 mục đầu tiên (24 giờ) để hiển thị
    final displayList = hourlyForecasts.take(8).toList();

    if (displayList.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị gì nếu list rỗng
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Căn tiêu đề sang trái
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0), // Thêm padding cho tiêu đề
          child: Text(
            'Dự báo hàng giờ', // Tiêu đề
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 130, // Chiều cao cố định cho ListView ngang
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Cuộn ngang
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];
              final itemTime = item.dtTxt;
              final itemTemp = item.main.temp;
              final itemWeather = item.weather.firstOrNull;
              // Lấy icon code từ enum đã đổi tên
              final WeatherIconEnum? itemIconEnum = itemWeather?.icon;
              final String? itemIconCode = itemIconEnum != null ? weatherIconEnumValues.reverse[itemIconEnum] : null;
              // Tạo URL icon bằng constants
              final itemIconUrl = itemIconCode != null ? '${ApiConstants.weatherIconBaseUrl}$itemIconCode${ApiConstants.weatherIconSuffix}' : null;

              // --- UI cho từng mục hàng giờ ---
              return Container(
                width: 70, // Chiều rộng mỗi mục
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Hiển thị Giờ (HH)
                    Text(
                      itemTime != null ? '${itemTime.hour.toString().padLeft(2, '0')}' : '--',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Icon
                    if (itemIconUrl != null)
                      Image.network(itemIconUrl, width: 40, height: 40, errorBuilder: (c, e, s) => const SizedBox(width: 40))
                    else
                      const SizedBox(width: 40, height: 40),
                    // Nhiệt độ
                    Text('${itemTemp.toStringAsFixed(0)}°'),
                  ],
                ),
              );
              // --- Kết thúc UI cho từng mục ---
            },
          ),
        ),
      ],
    );
  }
}

