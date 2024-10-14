import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey = '6ff03ac78fca0bea767f11d2524f5141';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getWeatherData(String location) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/weather?q=$location&units=metric&appid=$apiKey'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> getForecastData(String location) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/forecast?q=$location&units=metric&appid=$apiKey'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
  Future<List<Map<String, dynamic>>> getFiveDayForecast(String location) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey&units=metric&lang=vi'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Chuyển đổi dữ liệu thành danh sách dự báo
      List<Map<String, dynamic>> forecasts = [];
      for (var item in data['list']) {
        forecasts.add({
          'weekday': DateFormat.E().format(DateTime.parse(item['dt_txt'])),
          'day': DateFormat('dd/MM').format(DateTime.parse(item['dt_txt'])), // Ngày dự báo
          'temp': item['main']['temp'].toInt(), // Nhiệt độ
          'tempMin': item['main']['temp_min'].toInt(), // Nhiệt độ tối thiểu
          'tempMax': item['main']['temp_max'].toInt(), // Nhiệt độ tối đa
          'icon': item['weather'][0]['icon'], // Icon thời tiết
          'condition': item['weather'][0]['description'], // Điều kiện thời tiết
          'windSpeed': item['wind']['speed'], // Tốc độ gió
          'windDirection': item['wind']['deg'], // Hướng gió
          'humidity': item['main']['humidity'], // Độ ẩm
        });
      }
      return forecasts;
    } else {
      throw Exception('Không thể lấy dữ liệu dự báo');
    }
  }

}