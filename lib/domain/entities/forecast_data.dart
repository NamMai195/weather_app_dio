// lib/domain/entities/forecast_data.dart
// ĐÃ SỬA LỖI: Thêm xử lý null safety trong các hàm fromJson

import 'dart:convert';
import 'package:equatable/equatable.dart'; // Thêm Equatable cho các lớp chính

// --- Helper function và Enums ---
// Helper function để parse DateTime an toàn
DateTime? _parseDateTimeSafe(String? dateString) {
  if (dateString == null) return null;
  return DateTime.tryParse(dateString); // Dùng tryParse thay vì parse
}

// Helper function để parse Enum an toàn
T? _parseEnumSafe<T>(Map<String, T>? enumMap, String? key) {
  if (enumMap == null || key == null) return null;
  return enumMap[key]; // Không dùng '!', trả về null nếu không tìm thấy
}

// --- Các lớp Model ---

ForecastData forecastDataFromJson(String str) => ForecastData.fromJson(json.decode(str));

String forecastDataToJson(ForecastData data) => json.encode(data.toJson());

class ForecastData extends Equatable {
  final String cod;
  final int message;
  final int cnt;
  final List<ListElement> list;
  final City city;

  const ForecastData({
    required this.cod,
    required this.message,
    required this.cnt,
    required this.list,
    required this.city,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) => ForecastData(
    cod: json["cod"] ?? 'N/A', // Thêm default
    message: json["message"] ?? 0, // Thêm default
    cnt: json["cnt"] ?? 0, // Thêm default
    // Xử lý list null
    list: json["list"] == null
        ? []
        : List<ListElement>.from(
        (json["list"] as List<dynamic>).map((x) => ListElement.fromJson(x))),
    city: City.fromJson(json["city"] ?? {}), // Cung cấp map rỗng nếu city null
  );

  Map<String, dynamic> toJson() => {
    "cod": cod,
    "message": message,
    "cnt": cnt,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
    "city": city.toJson(),
  };

  @override
  List<Object?> get props => [cod, message, cnt, list, city];
}

class City extends Equatable {
  final int id;
  final String name;
  final Coord coord;
  final String country;
  final int population;
  final int timezone;
  final int sunrise;
  final int sunset;

  const City({
    required this.id,
    required this.name,
    required this.coord,
    required this.country,
    required this.population,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json["id"] ?? 0, // Thêm default
    name: json["name"] ?? 'N/A', // Thêm default
    coord: Coord.fromJson(json["coord"] ?? {}), // Cung cấp map rỗng nếu coord null
    country: json["country"] ?? 'N/A', // Thêm default
    population: json["population"] ?? 0, // Thêm default
    timezone: json["timezone"] ?? 0, // Thêm default
    sunrise: json["sunrise"] ?? 0, // Thêm default
    sunset: json["sunset"] ?? 0, // Thêm default
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "coord": coord.toJson(),
    "country": country,
    "population": population,
    "timezone": timezone,
    "sunrise": sunrise,
    "sunset": sunset,
  };

  @override
  List<Object?> get props => [id, name, coord, country, population, timezone, sunrise, sunset];
}

class Coord extends Equatable {
  final double lat;
  final double lon;

  const Coord({
    required this.lat,
    required this.lon,
  });

  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
    // Thêm ?? 0.0
    lat: json["lat"]?.toDouble() ?? 0.0,
    lon: json["lon"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lon": lon,
  };

  @override
  List<Object?> get props => [lat, lon];
}

class ListElement extends Equatable {
  final int dt;
  final MainClass main;
  final List<Weather> weather;
  final Clouds clouds;
  final Wind wind;
  final int visibility;
  final double pop; // Probability of precipitation
  final Rain? rain; // rain có thể null
  final Sys sys;
  final DateTime? dtTxt; // DateTime có thể null nếu parse lỗi

  const ListElement({
    required this.dt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.pop,
    this.rain,
    required this.sys,
    this.dtTxt, // Cập nhật constructor
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    dt: json["dt"] ?? 0, // Thêm default
    main: MainClass.fromJson(json["main"] ?? {}), // Cung cấp map rỗng
    // Xử lý list null
    weather: json["weather"] == null
        ? []
        : List<Weather>.from(
        (json["weather"] as List<dynamic>).map((x) => Weather.fromJson(x))),
    clouds: Clouds.fromJson(json["clouds"] ?? {}), // Cung cấp map rỗng
    wind: Wind.fromJson(json["wind"] ?? {}), // Cung cấp map rỗng
    visibility: json["visibility"] ?? 0, // Thêm default
    pop: json["pop"]?.toDouble() ?? 0.0, // Thêm default
    rain: json["rain"] == null ? null : Rain.fromJson(json["rain"]), // Giữ nguyên vì rain là nullable
    sys: Sys.fromJson(json["sys"] ?? {}), // Cung cấp map rỗng
    // Xử lý parse DateTime an toàn
    dtTxt: _parseDateTimeSafe(json["dt_txt"]),
  );

  Map<String, dynamic> toJson() => {
    "dt": dt,
    "main": main.toJson(),
    "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
    "clouds": clouds.toJson(),
    "wind": wind.toJson(),
    "visibility": visibility,
    "pop": pop,
    "rain": rain?.toJson(),
    "sys": sys.toJson(),
    "dt_txt": dtTxt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [dt, main, weather, clouds, wind, visibility, pop, rain, sys, dtTxt];
}

class Clouds extends Equatable {
  final int all;

  const Clouds({
    required this.all,
  });

  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
    all: json["all"] ?? 0, // Thêm default
  );

  Map<String, dynamic> toJson() => {
    "all": all,
  };

  @override
  List<Object?> get props => [all];
}

class MainClass extends Equatable {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int seaLevel;
  final int grndLevel;
  final int humidity;
  final double tempKf;

  const MainClass({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.seaLevel,
    required this.grndLevel,
    required this.humidity,
    required this.tempKf,
  });

  factory MainClass.fromJson(Map<String, dynamic> json) => MainClass(
    // Thêm ?? 0.0
    temp: json["temp"]?.toDouble() ?? 0.0,
    feelsLike: json["feels_like"]?.toDouble() ?? 0.0,
    tempMin: json["temp_min"]?.toDouble() ?? 0.0,
    tempMax: json["temp_max"]?.toDouble() ?? 0.0,
    // Thêm ?? 0
    pressure: json["pressure"] ?? 0,
    seaLevel: json["sea_level"] ?? 0,
    grndLevel: json["grnd_level"] ?? 0,
    humidity: json["humidity"] ?? 0,
    // Thêm ?? 0.0
    tempKf: json["temp_kf"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "sea_level": seaLevel,
    "grnd_level": grndLevel,
    "humidity": humidity,
    "temp_kf": tempKf,
  };

  @override
  List<Object?> get props => [temp, feelsLike, tempMin, tempMax, pressure, seaLevel, grndLevel, humidity, tempKf];
}

class Rain extends Equatable {
  final double the3H;

  const Rain({
    required this.the3H,
  });

  factory Rain.fromJson(Map<String, dynamic> json) => Rain(
    // Thêm ?? 0.0
    the3H: json["3h"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "3h": the3H,
  };

  @override
  List<Object?> get props => [the3H];
}

class Sys extends Equatable {
  final Pod? pod; // Đổi thành nullable

  const Sys({
    this.pod, // Cập nhật constructor
  });

  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
    // Parse Enum an toàn
    pod: _parseEnumSafe(podValues.map, json["pod"]),
  );

  Map<String, dynamic> toJson() => {
    "pod": podValues.reverse[pod],
  };

  @override
  List<Object?> get props => [pod];
}

enum Pod { D, N }

final podValues = EnumValues({"d": Pod.D, "n": Pod.N});

class Weather extends Equatable {
  final int id;
  final MainEnum? main; // Đổi thành nullable
  final Description? description; // Đổi thành nullable
  final Icon? icon; // Đổi thành nullable

  const Weather({
    required this.id,
    this.main, // Cập nhật constructor
    this.description, // Cập nhật constructor
    this.icon, // Cập nhật constructor
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json["id"] ?? 0, // Thêm default
    // Parse Enum an toàn
    main: _parseEnumSafe(mainEnumValues.map, json["main"]),
    description: _parseEnumSafe(descriptionValues.map, json["description"]),
    icon: _parseEnumSafe(iconValues.map, json["icon"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "main": mainEnumValues.reverse[main],
    "description": descriptionValues.reverse[description],
    "icon": iconValues.reverse[icon],
  };

  @override
  List<Object?> get props => [id, main, description, icon];
}

// --- Định nghĩa các Enum và EnumValues ---
// (Giữ nguyên các định nghĩa enum Pod, Description, Icon, MainEnum và class EnumValues<T> như code Nam đã gửi)
// Tốt hơn nên có một giá trị default/unknown cho mỗi Enum
enum Description {
  MA_NH, MY_CM, MY_EN_U_M, MY_RI_RC, MY_THA, UNKNOWN
}
final descriptionValues = EnumValues({
  "mưa nhẹ": Description.MA_NH,
  "mây cụm": Description.MY_CM,
  "mây đen u ám": Description.MY_EN_U_M,
  "mây rải rác": Description.MY_RI_RC,
  "mây thưa": Description.MY_THA
}); // Thiếu Unknown ở đây, nên xử lý trong _parseEnumSafe hoặc thêm vào map

enum Icon {
  THE_02_N, THE_03_N, THE_04_D, THE_04_N, THE_10_D, THE_10_N, UNKNOWN
}
final iconValues = EnumValues({
  "02n": Icon.THE_02_N, "03n": Icon.THE_03_N, "04d": Icon.THE_04_D,
  "04n": Icon.THE_04_N, "10d": Icon.THE_10_D, "10n": Icon.THE_10_N
}); // Thiếu Unknown

enum MainEnum { CLOUDS, RAIN, UNKNOWN }
final mainEnumValues = EnumValues({
  "Clouds": MainEnum.CLOUDS, "Rain": MainEnum.RAIN
}); // Thiếu Unknown

// EnumValues class (Giữ nguyên)
class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
// --- Kết thúc định nghĩa Enum ---


class Wind extends Equatable {
  final double speed;
  final int deg;
  final double gust;

  const Wind({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    // Thêm ?? 0.0
    speed: json["speed"]?.toDouble() ?? 0.0,
    // Thêm ?? 0
    deg: json["deg"] ?? 0,
    // Thêm ?? 0.0
    gust: json["gust"]?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "speed": speed,
    "deg": deg,
    "gust": gust,
  };

  @override
  List<Object?> get props => [speed, deg, gust];
}