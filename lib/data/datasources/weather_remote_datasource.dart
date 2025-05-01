abstract class WeatherRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentWeather(String city);

  Future<List<dynamic>> getCitySuggestionDate(String query);
}


