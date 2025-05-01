import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:weather_app/data/datasources/impl/weather_remote_datasource_impl.dart';
import 'package:weather_app/data/datasources/weather_remote_datasource.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/bloc/weather_bloc.dart';

//tao mot instance toan cuc
final GetIt locator = GetIt.instance;

//Hammm setup dang dependencies
void setupLocator() {
  print('Setting up locator...');

  // ---Dang ky Dep


  //Dio
  //Lazy Singleton: Tạo instance khi cần và tái sử dụng nó
  locator.registerLazySingleton<Dio>(() {
    print('Creating Dio instance');

    return Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10)
    ));
  });

  //WeatherRemoteDataSource
  locator.registerLazySingleton<WeatherRemoteDataSource>(() {
    print('Creating WeatherRemoteDataSourceImpl instance');
    return WeatherRemoteDataSourceImpl(dio: locator<Dio>());
  });


  //WeatherRepository
  locator.registerLazySingleton<WeatherRepository>((){
    print('Creating WeatherRepositoryImpl instance');
    return WeatherRepositoryImpl(remoteDataSource: locator<WeatherRemoteDataSource>());
  });


  //WeatherBloc
  //dung factory vi thuong moi khi goi thi tao moi instance
  locator.registerFactory<WeatherBloc>((){
    print('Creating WeatherBloc instance');
    return WeatherBloc(weatherRepository: locator<WeatherRepository>());
  });

  //
  print('Locator setup complete!');
}