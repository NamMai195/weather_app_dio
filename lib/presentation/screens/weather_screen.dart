import 'package:flutter/material.dart'; // Quan trọng: import thư viện material

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Ô nhập tên thành phố
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Nhập tên thành phố',
                hintText: 'Ví dụ: Hanoi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20), // Khoảng cách

            // Nút bấm
            ElevatedButton(
              onPressed: () {
                final cityName = _cityController.text;
                print('Thành phố đã nhập: $cityName');
                // Logic gọi API sẽ thêm sau
              },
              child: const Text('Xem Thời Tiết'),
            ),
            const SizedBox(height: 30), // Khoảng cách

            // Khu vực hiển thị kết quả (Placeholder)
            const Center(
              child: Text(
                'Kết quả thời tiết sẽ hiển thị ở đây...',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose(); // Clean up the controller
    super.dispose();
  }
}