import 'dart:convert';
import 'package:equatable/equatable.dart';

DateTime? _parseDateTimeSafe(String? dateString) {
  if (dateString == null) return null;
  return DateTime.tryParse(dateString);
}

T? _parseEnumSafe<T>(Map<String, T>? enumMap, String? key) {
  if (enumMap == null || key == null) return null;
  return enumMap[key];
}


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
    cod: json["cod"] ?? 'N/A',
    message: json["message"] ?? 0,
    cnt: json["cnt"] ?? 0,
    // Xử lý list null
    list: json["list"] == null
        ? []
        : List<ListElement>.from(
        (json["list"] as List<dynamic>).map((x) => ListElement.fromJson(x))),
    city: City.fromJson(json["city"] ?? {}),
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
    id: json["id"] ?? 0,
    name: json["name"] ?? 'N/A',
    coord: Coord.fromJson(json["coord"] ?? {}),
    country: json["country"] ?? 'N/A',
    population: json["population"] ?? 0,
    timezone: json["timezone"] ?? 0,
    sunrise: json["sunrise"] ?? 0,
    sunset: json["sunset"] ?? 0,
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
  final double pop;
  final Rain? rain;
  final Sys sys;
  final DateTime? dtTxt;

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
    this.dtTxt,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    dt: json["dt"] ?? 0,
    main: MainClass.fromJson(json["main"] ?? {}),
    // Xử lý list null
    weather: json["weather"] == null
        ? []
        : List<Weather>.from(
        (json["weather"] as List<dynamic>).map((x) => Weather.fromJson(x))),
    clouds: Clouds.fromJson(json["clouds"] ?? {}),
    wind: Wind.fromJson(json["wind"] ?? {}),
    visibility: json["visibility"] ?? 0,
    pop: json["pop"]?.toDouble() ?? 0.0,
    rain: json["rain"] == null ? null : Rain.fromJson(json["rain"]),
    sys: Sys.fromJson(json["sys"] ?? {}),
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
    all: json["all"] ?? 0,
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
    temp: json["temp"]?.toDouble() ?? 0.0,
    feelsLike: json["feels_like"]?.toDouble() ?? 0.0,
    tempMin: json["temp_min"]?.toDouble() ?? 0.0,
    tempMax: json["temp_max"]?.toDouble() ?? 0.0,
    pressure: json["pressure"] ?? 0,
    seaLevel: json["sea_level"] ?? 0,
    grndLevel: json["grnd_level"] ?? 0,
    humidity: json["humidity"] ?? 0,
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
  final Pod? pod;

  const Sys({
    this.pod,
  });

  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
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
  final MainEnum? main;
  final Description? description;
  final Icon? icon;

  const Weather({
    required this.id,
    this.main,
    this.description,
    this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    id: json["id"] ?? 0,
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


enum Description {
  MA_NH, MY_CM, MY_EN_U_M, MY_RI_RC, MY_THA, UNKNOWN
}
final descriptionValues = EnumValues({
  "mưa nhẹ": Description.MA_NH,
  "mây cụm": Description.MY_CM,
  "mây đen u ám": Description.MY_EN_U_M,
  "mây rải rác": Description.MY_RI_RC,
  "mây thưa": Description.MY_THA
});

enum Icon {
  THE_02_N, THE_03_N, THE_04_D, THE_04_N, THE_10_D, THE_10_N, UNKNOWN
}
final iconValues = EnumValues({
  "02n": Icon.THE_02_N, "03n": Icon.THE_03_N, "04d": Icon.THE_04_D,
  "04n": Icon.THE_04_N, "10d": Icon.THE_10_D, "10n": Icon.THE_10_N
});

enum MainEnum { CLOUDS, RAIN, UNKNOWN }
final mainEnumValues = EnumValues({
  "Clouds": MainEnum.CLOUDS, "Rain": MainEnum.RAIN
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}



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
    speed: json["speed"]?.toDouble() ?? 0.0,
    deg: json["deg"] ?? 0,
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