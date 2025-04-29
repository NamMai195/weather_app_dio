# Flutter Weather App (Dio + BLoC)

Một ứng dụng Flutter đơn giản để hiển thị thông tin thời tiết hiện tại từ [OpenWeatherMap API](https://openweathermap.org/api), sử dụng thư viện `dio` cho networking và `flutter_bloc` để quản lý trạng thái, theo kiến trúc Clean Architecture.

Đây là project thực hành nhằm củng cố kiến thức về Flutter, API, State Management và kiến trúc phần mềm.

## Tính năng

* Tìm kiếm thời tiết theo tên thành phố.
* Hiển thị thông tin thời tiết hiện tại:
    * Nhiệt độ (°C)
    * Điều kiện thời tiết (mô tả, icon)
    * Độ ẩm (%)
    * Tốc độ gió (m/s)
* Hiển thị chỉ báo đang tải (loading indicator) khi đang lấy dữ liệu.
* Hiển thị thông báo lỗi thân thiện khi có sự cố.

## Kiến trúc & Công nghệ

* **Kiến trúc:** Clean Architecture (`domain`, `data`, `presentation`)
* **State Management:** `flutter_bloc`
* **Networking:** `dio`
* **Dependency Injection:** Thủ công (thông qua `BlocProvider`)
* **Models:** Tạo từ JSON bằng Quicktype

## Bắt đầu

### Điều kiện tiên quyết

* Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).

### Cài đặt         

1.  **Clone repository:**
    ```bash
    git clone [https://github.com/NamMai195/weather_app_dio.git](https://github.com/NamMai195/weather_app_dio.git)
    cd weather_app_dio
    ```

2.  **Thiết lập API Key:**
    * Đăng ký tài khoản miễn phí và lấy API key từ [OpenWeatherMap](https://openweathermap.org/appid).
    * Trong thư mục `lib` của dự án, tạo một file mới tên là `config.dart`.
    * Thêm nội dung sau vào file `lib/config.dart`, thay thế `"YOUR_API_KEY"` bằng API key thực tế của bạn:
        ```dart
        // lib/config.dart
        const String openWeatherApiKey = "YOUR_API_KEY";
        ```
    * **Quan trọng:** File `config.dart` đã được thêm vào `.gitignore` để đảm bảo API key không bị đưa lên repository.

3.  **Cài đặt dependencies:**
    ```bash
    flutter pub get
    ```
f
4.  **Chạy ứng dụng:**
    ```bash
    flutter run
    ```

## Tác giả

* [NamMai195](https://github.com/NamMai195)