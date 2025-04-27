// lib/main.dart
import 'package:flutter/material.dart';
// Import màn hình WeatherScreen từ vị trí mới trong presentation layer
import 'presentation/screens/weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Sử dụng WeatherScreen làm màn hình chính
      home: const WeatherScreen(),
    );
  }
}
