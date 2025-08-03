import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cek_cuaca/models/weather_model.dart';
import 'package:cek_cuaca/models/forecast_model.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;
  WeatherService(this.apiKey);

  Future<Weather> getCurrentWeatherByCity(String cityName) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?q=$cityName&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat data cuaca saat ini.');
    }
  }
  
  // Fungsi tambahan untuk mendapatkan data mentah (raw)
  Future<Map<String, dynamic>> getRawWeatherByCity(String cityName) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?q=$cityName&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data cuaca mentah.');
    }
  }

  Future<Weather> getCurrentWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat data cuaca saat ini.');
    }
  }

  Future<List<Forecast>> getFiveDayForecastByCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List forecastList = data['list'];
      return forecastList.map((item) => Forecast.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data prakiraan cuaca.');
    }
  }
  
  Future<List<dynamic>> getCitySuggestions(String query) async {
    final url = 'https://www.emsifa.com/api-wilayah-indonesia/api/search/cities.json?q=${query.toLowerCase()}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}