// lib/domain/entities/weather.dart
// Đã cập nhật để xử lý null trong fromJson

import 'dart:convert';

WeatherData weatherDataFromJson(String str) =>
    WeatherData.fromJson(json.decode(str));

String weatherDataToJson(WeatherData data) => json.encode(data.toJson());

class WeatherData {
  Coord coord;
  List<Weather> weather;
  String base;
  Main main;
  int visibility;
  Wind wind;
  Clouds clouds;
  int dt;
  Sys sys;
  int timezone;
  int id;
  String name;
  int cod;

  WeatherData({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  // Đã cập nhật các trường int với ?? 0
  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    coord: Coord.fromJson(json["coord"]),
    weather: List<Weather>.from(
      // Nên kiểm tra json["weather"] có null không trước khi map
      (json["weather"] as List<dynamic>? ?? [])
          .map((x) => Weather.fromJson(x)),
    ),
    base: json["base"] ?? '', // Thêm default cho String nếu cần
    main: Main.fromJson(json["main"]),
    visibility: json["visibility"] ?? 0, // Sửa ở đây
    wind: Wind.fromJson(json["wind"]),
    clouds: Clouds.fromJson(json["clouds"]),
    dt: json["dt"] ?? 0, // Sửa ở đây
    sys: Sys.fromJson(json["sys"]),
    timezone: json["timezone"] ?? 0, // Sửa ở đây
    id: json["id"] ?? 0, // Sửa ở đây
    name: json["name"] ?? 'N/A', // Thêm default cho String nếu cần
    cod: json["cod"] ?? 0, // Sửa ở đây
  );

  Map<String, dynamic> toJson() => {
    "coord": coord.toJson(),
    "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
    "base": base,
    "main": main.toJson(),
    "visibility": visibility,
    "wind": wind.toJson(),
    "clouds": clouds.toJson(),
    "dt": dt,
    "sys": sys.toJson(),
    "timezone": timezone,
    "id": id,
    "name": name,
    "cod": cod,
  };
}

class Clouds {
  int all;

  Clouds({required this.all});

  // Đã cập nhật với ?? 0
  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
    all: json["all"] ?? 0, // Sửa ở đây
  );

  Map<String, dynamic> toJson() => {"all": all};
}

class Coord {
  double lon;
  double lat;

  Coord({required this.lon, required this.lat});

  // Đã cập nhật với ?? 0.0
  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
    lon: json["lon"]?.toDouble() ?? 0.0, // Sửa ở đây
    lat: json["lat"]?.toDouble() ?? 0.0, // Sửa ở đây
  );

  Map<String, dynamic> toJson() => {"lon": lon, "lat": lat};
}

class Main {
  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;
  int? seaLevel; // Thay đổi thành nullable nếu 0 không hợp lý làm default
  int? grndLevel; // Thay đổi thành nullable nếu 0 không hợp lý làm default

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    this.seaLevel, // Cập nhật constructor
    this.grndLevel, // Cập nhật constructor
  });

  // Đã cập nhật các trường int/double với ??
  factory Main.fromJson(Map<String, dynamic> json) => Main(
    temp: json["temp"]?.toDouble() ?? 0.0, // Sửa ở đây
    feelsLike: json["feels_like"]?.toDouble() ?? 0.0, // Sửa ở đây
    tempMin: json["temp_min"]?.toDouble() ?? 0.0, // Sửa ở đây
    tempMax: json["temp_max"]?.toDouble() ?? 0.0, // Sửa ở đây
    pressure: json["pressure"] ?? 0, // Sửa ở đây
    humidity: json["humidity"] ?? 0, // Sửa ở đây
    seaLevel: json["sea_level"], // Giữ nguyên, vì đã là int?
    grndLevel: json["grnd_level"], // Giữ nguyên, vì đã là int?
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "humidity": humidity,
    "sea_level": seaLevel,
    "grnd_level": grndLevel,
  };
}

class Sys {
  int? type; // Có thể null
  int? id; // Có thể null
  String? country; // Có thể null
  int? sunrise; // Có thể null
  int? sunset; // Có thể null

  Sys({
    this.type,
    this.id,
    this.country,
    this.sunrise,
    this.sunset,
  });

  // Đã cập nhật các trường int với ?? 0 (hoặc giữ null nếu trường là nullable)
  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
    type: json["type"],         // Giữ null nếu cần
    id: json["id"],             // Giữ null nếu cần
    country: json["country"],   // Giữ null nếu cần
    sunrise: json["sunrise"], // Giữ null nếu cần
    sunset: json["sunset"],   // Giữ null nếu cần
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "id": id,
    "country": country,
    "sunrise": sunrise,
    "sunset": sunset,
  };
}

class Weather {
  int id;
  String main;
  String description;
  String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  // Đã cập nhật các trường int với ?? 0
  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json["id"] ?? 0, // Sửa ở đây
    main: json["main"] ?? '', // Thêm default cho String nếu cần
    description: json["description"] ?? '', // Thêm default cho String nếu cần
    icon: json["icon"] ?? '', // Thêm default cho String nếu cần
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "main": main,
    "description": description,
    "icon": icon,
  };
}

class Wind {
  double speed;
  int deg;

  Wind({required this.speed, required this.deg});

  // Đã cập nhật các trường int/double với ??
  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    speed: json["speed"]?.toDouble() ?? 0.0, // Sửa ở đây
    deg: json["deg"] ?? 0, // Sửa ở đây
  );

  Map<String, dynamic> toJson() => {"speed": speed, "deg": deg};
}