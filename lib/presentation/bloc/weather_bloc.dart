import 'package:bloc/bloc.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/domain/entities/forecast_data.dart';
import 'package:weather_app/domain/entities/weather.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/locator.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart'; // Import Equatable

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(WeatherInitial()) {
    on<WeatherRequested>(_onWeatherRequested);
  }

  // Future<void> _onWeatherRequested(
  //   WeatherRequested event,
  //   Emitter<WeatherState> emit,
  // ) async {
  //   final String city = event.city;
  //   emit(WeatherLoadInProgress());
  //
  //   try {
  //     final WeatherData weatherData = await weatherRepository.getWeatherByCity(
  //       city,
  //     );
  //
  //     emit(WeatherLoadSuccess(weatherData));
  //   } catch (e) {
  //     emit(WeatherLoadFailure(e.toString()));
  //   }
  // }
  Future<void> _onWeatherRequested(
      WeatherRequested event,
      Emitter<WeatherState> emit,
      ) async {
    final String city = event.city;
    emit(WeatherLoadInProgress());

    try {
      print('BLoc: lay toa do cho :$city');
      final suggestions = await weatherRepository.getCitySuggestions(city);
      if (suggestions.isEmpty) {
        print('Bloc: khong tim thay toa do cho $city');
        emit(const WeatherLoadFailure('Khong tim thay thanh pho:'));
        return;
      }

      final firstSuggestion = suggestions.first;
      final geoDate =await locator<WeatherRemoteDataSource>().getCitySuggestionData(firstSuggestion.name,limit: 1);
      if(geoDate.isEmpty || geoDate.first['lat'] == null || geoDate.first['lon'] == null){
        throw Exception('Khong the xác định vị trí cho: $city');
      }
      final double lat=geoDate.first['lat'];
      final double lon=geoDate.first['lon'];

      print('Bloc: toa do tim duoc :Lat=$lat , Lon=$lon');
      print('Bloc Bat dau goi dong thoi api thoi tiet va du bao');

      final results= await Future.wait([
        weatherRepository.getCurrentWeatherCoords(lat: lat,lon: lon),
        weatherRepository.getForecastData(lat: lat, lon: lon)
      ]);
      if(results.length==2 && results[0] is WeatherData && results[1] is ForecastData) {
        final weatherDate = results[0] as WeatherData;
        final forecastData= results[1] as ForecastData;

        print('Bloc: goi 2 api thanh cong');
        emit(WeatherLoadSuccess(weatherDate, forecastData));
      } else {
        print('Bloc: loi kieu tu lieu tra ve tu Future.wait');
        throw Exception('Loi xu ly du lieu tra ve tu API');
      }
    } catch (e) {
      print('BLoC: Lỗi trong _onWeatherRequested: ${e.toString()}');
      emit(WeatherLoadFailure(e.toString()));
    }
  }
}
