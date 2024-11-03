import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchWeatherData(String city) async {
  const apiKey = 'bc84f63356ddb3bd796d95f04f29ce77'; // Thay bằng API key của bạn
  final weatherUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=vi';

  try {
    // Gọi API thời tiết
    final weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode == 200) {
      final weatherData = jsonDecode(weatherResponse.body);
      final lat = weatherData['coord']['lat'];
      final lon = weatherData['coord']['lon'];

      // Gọi API chất lượng không khí (Air Pollution)
      final airPollutionUrl = 'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
      final airPollutionResponse = await http.get(Uri.parse(airPollutionUrl));

      String airQuality = "Không có dữ liệu";
      if (airPollutionResponse.statusCode == 200) {
        final airPollutionData = jsonDecode(airPollutionResponse.body);
        final aqi = airPollutionData['list'][0]['main']['aqi'];
        airQuality = _getAirQuality(aqi); // Xử lý AQI từ 1-5
      }

      // Trả về dữ liệu kết hợp thời tiết và chất lượng không khí
      return {
        'temperature': '${weatherData['main']['temp']}°C',
        'weatherStatus': weatherData['weather'][0]['description'],
        'weatherIcon': _getWeatherIcon(weatherData['weather'][0]['id']),
        'airQuality': airQuality,
        'humidity': '${weatherData['main']['humidity']}%',
      };
    } else {
      throw Exception('Failed to load weather data');
    }
  } catch (e) {
    print(e);
    return null;
  }
}

IconData _getWeatherIcon(int weatherId) {
  if (weatherId < 300) return Icons.thunderstorm;
  if (weatherId < 400) return Icons.cloud;
  if (weatherId < 600) return Icons.grain;
  if (weatherId < 700) return Icons.ac_unit;
  if (weatherId < 800) return Icons.wb_cloudy;
  return Icons.wb_sunny;
}

String _getAirQuality(int aqi) {
  switch (aqi) {
    case 1:
      return "Tốt";
    case 2:
      return "Trung bình";
    case 3:
      return "Kém";
    case 4:
      return "Xấu";
    case 5:
      return "Rất xấu";
    default:
      return "Không có dữ liệu";
  }
}
