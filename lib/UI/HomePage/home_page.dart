import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather/Components/color.dart';
import 'package:weather/UI/DrugsPage/drug_look_page.dart';
import 'package:weather/UI/DrugsPage/drug_lookup_card.dart';
import 'package:weather/UI/HomePage/feature_card.dart';
import 'package:weather/UI/HomePage/weather_detail_page.dart';
import 'package:weather/UI/PlantPage/MyPlant.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<String> cities = ["Bình Trị Đông", "Hà Nội", "Đà Nẵng"];
  int currentIndex = 0;
  String temperature = "Đang tải...";
  String weatherStatus = "Đang tải...";
  IconData weatherIcon = Icons.wb_cloudy;
  String airQuality = "Đang tải...";
  String humidity = "Đang tải...";
  String location = "Đang xác định...";
  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  // Hàm lấy vị trí hiện tại của người dùng
  // Hàm lấy vị trí hiện tại của người dùng
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Dịch vụ định vị chưa được bật");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Quyền truy cập vị trí bị từ chối");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Quyền truy cập vị trí bị từ chối vĩnh viễn");
    }

    return await Geolocator.getCurrentPosition();
  }
  // Hàm để lấy địa chỉ từ tọa độ GPS
  Future<void> _getAddressFromLatLon(double lat, double lon) async {
    const apiKey = 'AIzaSyAo2iS5n--Eb2KHKotKFUj8j0-xUn5aHWE'; // Thay bằng API Key của bạn

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['results'].isNotEmpty) {
          final addressComponents = result['results'][0]['address_components'];

          String street = '';
          String district = '';
          String city = '';
          String neighborhood = ''; // Thêm biến cho phường

          for (var component in addressComponents) {
            final types = component['types'];
            if (types.contains('administrative_area_level_2')) {
              district = component['long_name']; // Quận
            } else if (types.contains('administrative_area_level_1')) {
              city = component['long_name']; // Thành phố
            } else if (types.contains('route')) {
              street = component['long_name']; // Đường
            } else if (types.contains('sublocality') || types.contains('neighborhood')) {
              neighborhood = component['long_name']; // Phường
            }
          }

          setState(() {
            // Hiển thị phường, quận, và thành phố
            location = '$neighborhood, $district, $city';
          });
        } else {
          throw Exception("Không tìm thấy địa chỉ từ tọa độ");
        }
      } else {
        throw Exception("Failed to fetch address");
      }
    } catch (e) {
      setState(() {
        location = "Không xác định được vị trí";
      });
    }
  }




  // Hàm tải dữ liệu thời tiết từ OpenWeather
  Future<void> fetchWeather() async {
    setState(() {
      temperature = "Đang tải...";
      weatherStatus = "Đang tải...";
      airQuality = "Đang tải...";
      humidity = "Đang tải...";
    });
    try {
      Position position = await _getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;
      print('Latitude: $lat, Longitude: $lon');
      // Gọi API Geocoding để lấy địa chỉ
      await _getAddressFromLatLon(lat, lon);

      // Thêm logic tải dữ liệu thời tiết tại đây...
    } catch (e) {
      setState(() {
        location = "Không xác định được vị trí";
      });
    }


    const apiKey = '6ff03ac78fca0bea767f11d2524f5141'; // Thay bằng API key của bạn
    try {
      Position position = await _getCurrentLocation();
      final lat = position.latitude;
      final lon = position.longitude;
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          temperature = result['main']['temp'].round().toString() + "°C";
          weatherStatus = result['weather'][0]['description'];
          weatherIcon = _getWeatherIcon(result['weather'][0]['id']);
          airQuality = _getAirQuality(result['main']['humidity']);
          humidity = result['main']['humidity'].toString() + "%";
          location = result['name']; // Hiển thị tên địa điểm
          double tempMin = result['main']['temp_min'];
          double tempMax = result['main']['temp_max'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        temperature = "No data";
        weatherStatus = "No data";
        airQuality = "No data";
        humidity = "No data";
        location = "Không xác định được vị trí";
      });
    }
  }

  // Hàm lấy biểu tượng thời tiết dựa trên mã thời tiết
  IconData _getWeatherIcon(int weatherId) {
    if (weatherId < 300) return Icons.thunderstorm;
    if (weatherId < 400) return Icons.cloud;
    if (weatherId < 600) return Icons.grain;
    if (weatherId < 700) return Icons.ac_unit;
    if (weatherId < 800) return Icons.wb_cloudy;
    return Icons.wb_sunny;
  }

  // Hàm trả về chất lượng không khí (giả lập bằng độ ẩm)
  String _getAirQuality(int humidity) {
    if (humidity < 30) return "Tốt";
    if (humidity < 60) return "Trung bình";
    return "Xấu";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section hiển thị thời tiết
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherDetailPage(
                          location: location,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.location_city, color: blackColor),
                      Text(
                        location,
                        style: TextStyle(fontSize: 20, color: blackColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: fetchWeather,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row chứa chi tiết thời tiết và thẻ độ ẩm/chất lượng không khí
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeatherDetailPage(
                              location: location,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue[100],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(weatherIcon, size: 30),
                              Text(
                                temperature,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      weatherStatus,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IntrinsicWidth(
                      child: Column(
                        children: [
                          // Thẻ cho Chất lượng không khí
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeatherDetailPage(
                                    location: location,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text("Chỉ số chất lượng\n không khí:", style: TextStyle(fontSize: 16)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.masks, color: Colors.blue),
                                        SizedBox(width: 5),
                                        Text(
                                          airQuality,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeatherDetailPage(
                                    location: location,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text("Độ ẩm:", style: TextStyle(fontSize: 16)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.water, color: Colors.blue),
                                        SizedBox(width: 5),
                                        Text(
                                          humidity,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            const Text(
              "Tính năng nổi bật",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FeatureCard(icon: Icons.local_florist, label: "Bác sĩ cây AI"),
                  FeatureCard(icon: Icons.shield, label: "Bảo hiểm lượng mưa"),
                  FeatureCard(icon: Icons.qr_code, label: "Truy xuất nguồn gốc"),
                  FeatureCard(icon: Icons.directions_bus, label: "Chuyến xe nông dân"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const DrugLookupCard(),
            const SizedBox(height: 20),
            MyPlantsScreen(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


}



