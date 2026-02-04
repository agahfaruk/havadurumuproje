import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:havadurumuproje/models/weather_models.dart';

class WeatherService {
  Future<String> _getLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisi devre dışı.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izini vermelisiniz.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izni kalıcı olarak reddedildi.');
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final List<Placemark> placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? city = placemark[0].administrativeArea ?? placemark[0].locality;
    
    if (city == null) return Future.error('Şehir bilgisi alınamadı');

    city = city.split(' ').first; 
    
    return city;
  }

  Future<List<WeatherModels>> getWeather() async {
    try {
      final String city = await _getLocation();

      final String url =
          'https://api.collectapi.com/weather/getWeather?lang=tr&city=$city';
      const Map<String, dynamic> headers = {
        'authorization': 'apikey 4Utq9XsdrMuLTUx6mIBpfO:3HWqhaUs2az7dMJIrcckJE',
        'content-type': 'application/json',
      };

      final dio = Dio();
      final response = await dio.get(url, options: Options(headers: headers));

      if (response.statusCode != 200) {
        return Future.error("Sunucu hatası: ${response.statusCode}");
      }

      // Veriyi dynamic olarak alıyoruz ki tip hatası vermesin
      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      List resultList = [];

      if (rawData is List) {
        // Eğer API doğrudan liste döndürdüyse
        resultList = rawData;
      } else if (rawData is Map) {
        // Eğer API bir nesne döndürdüyse (success, result vb.)
        if (rawData['success'] == false) {
          return Future.error("API Hatası: ${rawData['message']}");
        }
        resultList = rawData['result'] ?? [];
      }

      return resultList.map((e) => WeatherModels.fromJson(e)).toList();
    } catch (e) {
      return Future.error("Hava durumu alınamadı: $e");
    }
  }
}
