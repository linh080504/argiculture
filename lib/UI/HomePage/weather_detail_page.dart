import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để định dạng ngày tháng
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Database/API/weather_service.dart';

class WeatherDetailPage extends StatefulWidget {
  final String location;

  WeatherDetailPage({required this.location});

  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic> _weatherData = {};
  Map<String, dynamic> _forecastData = {};
  List<Map<String, dynamic>> fiveDayForecast = [];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    fetchFiveDayForecast(widget.location);
  }
  Future<void> fetchFiveDayForecast(String city) async {
    final apiKey = 'bc84f63356ddb3bd796d95f04f29ce77'; // Thay bằng API key của bạn
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey&lang=vi';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> forecastList = data['list'];
      print(forecastList);
      setState(() {
        fiveDayForecast = groupForecastByDay(forecastList);
      });
    } else {
      throw Exception('Failed to load forecast');
    }
  }
  List<Map<String, dynamic>> groupForecastByDay(List<dynamic> hourlyForecast) {
    Map<String, Map<String, dynamic>> groupedData = {};

    for (var forecast in hourlyForecast) {
      DateTime forecastTime =
      DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      String day = DateFormat('dd/MM').format(forecastTime);

      // Chọn dữ liệu tại thời điểm 12:00 trưa làm đại diện cho mỗi ngày
      if (!groupedData.containsKey(day)) {
        final minTemp = forecast['main']['temp_min'].round();
        final maxTemp = forecast['main']['temp_max'].round();
        final humidity = forecast['main']['humidity'];
        final condition = forecast['weather'][0]['description'];
        final icon = forecast['weather'][0]['icon'];
        final rain = forecast['rain'] != null
            ? forecast['rain']['3h']?.toString() ?? '0'
            : '0';

        // Thay đổi dòng này để tạo Map cho mỗi ngày
        groupedData[day] = {
          'day': day,
          'weekday': DateFormat('EEEE').format(forecastTime),
          'tempMin': minTemp,
          'tempMax': maxTemp,
          'humidity': humidity,
          'condition': condition,
          'icon': icon,
          'rain': rain,
        };
      }
    }

    return groupedData.values.toList().cast<Map<String, dynamic>>();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final weatherData = await _weatherService.getWeatherData(widget.location);
      final forecastData = await _weatherService.getForecastData(widget.location);
      setState(() {
        _weatherData = weatherData;
        _forecastData = forecastData;
      });
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final now = DateTime.now();
    final String temperature = _weatherData.isNotEmpty
        ? '${_weatherData['main']['temp'].round()}°C'
        : 'N/A';
    final String weatherCondition = _weatherData.isNotEmpty
        ? _weatherData['weather'][0]['main']
        : 'N/A';
    final String airQuality = 'N/A'; // OpenWeather không cung cấp dữ liệu này
    final String feelsLike = _weatherData.isNotEmpty
        ? '${_weatherData['main']['feels_like'].round()}°C'
        : 'N/A';
    final String windSpeed = _weatherData.isNotEmpty
        ? '${_weatherData['wind']['speed']} m/s'
        : 'N/A';
    final String humidity = _weatherData.isNotEmpty
        ? '${_weatherData['main']['humidity']}%'
        : 'N/A';

    // Sửa kiểu dữ liệu của hourlyForecast thành Map<String, dynamic>
    List<Map<String, dynamic>> hourlyForecast = [];
    if (_forecastData.isNotEmpty) {
      hourlyForecast = List<Map<String, dynamic>>.from(
        _forecastData['list'].where((item) {
          final forecastTime = DateTime.parse(item['dt_txt']);
          return forecastTime.isAfter(now) || forecastTime.isAtSameMomentAs(now);
        }).take(8).map((item) {
          return {
            "icon": item['weather'][0]['icon'], // Chỉ lấy tên icon từ dữ liệu
            "temp": '${item['main']['temp'].round()}°C',
            "condition": item['weather'][0]['main'],
            "windSpeed": '${item['wind']['speed']} m/s',
            "windDirection": _getWindDirection(item['wind']['deg']),
            "humidity": '${item['main']['humidity']}%',
            "time": DateFormat('HH:mm').format(DateTime.parse(item['dt_txt'])),
          };
        }),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sao.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                toolbarHeight: 100,
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
                title: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.location,
                        style: TextStyle(fontSize: 30, color: Colors.white),
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(height: 4),
                      Center(
                        child: Text(
                          currentDate,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                automaticallyImplyLeading: true,
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    _getWeatherImage(weatherCondition),
                                    width: 150, // Điều chỉnh kích thước hình ảnh nếu cần
                                    height: 150,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    temperature,
                                    style: TextStyle(
                                        fontSize: 60, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    weatherCondition,
                                    style: TextStyle(
                                        fontSize: 28, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Card(
                                    child: ListTile(
                                      title: Text(
                                          'Chất lượng không khí',
                                          style: TextStyle(fontSize: 18)),
                                      subtitle: Text(airQuality,
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  Card(
                                    child: ListTile(
                                      title: Text('Nhiệt độ cảm nhận',
                                          style: TextStyle(fontSize: 18)),
                                      subtitle: Text(feelsLike,
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  Card(
                                    child: ListTile(
                                      title: Text('Tốc độ gió',
                                          style: TextStyle(fontSize: 18)),
                                      subtitle: Text(windSpeed,
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  Card(
                                    child: ListTile(
                                      title: Text('Độ ẩm',
                                          style: TextStyle(fontSize: 18)),
                                      subtitle: Text(humidity,
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dự báo thời tiết hàng giờ',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: hourlyForecast.map((forecast) {
                                    return Column(  // Đặt Card và thời gian vào một Column để tách thời gian ra khỏi Card
                                      children: [
                                        Card(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 300,
                                            height: 180,
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column( // Bọc tất cả các phần tử trong Column để chứa nhiều widget con
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        FaIcon(
                                                          _getWeatherIcon(forecast["icon"] as String),
                                                          size: 50,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          '${forecast["temp"]}',
                                                          style: TextStyle(
                                                              fontSize: 28,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '${forecast["condition"]}',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 30),
                                                    VerticalDivider(color: Colors.black, width: 20),
                                                    SizedBox(width: 30),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Gió: ${forecast["windSpeed"]}',
                                                            style: TextStyle(fontSize: 20, color: Colors.white),
                                                          ),
                                                          SizedBox(height: 15),
                                                          Text(
                                                            'Hướng: ${forecast["windDirection"]}',
                                                            style: TextStyle(fontSize: 20, color: Colors.white),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            'Độ ẩm: ${forecast["humidity"]}',
                                                            style: TextStyle(fontSize: 18, color: Colors.white),
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5), // Cách giữa các thẻ
                                        Text(
                                          '${forecast["time"]}', // Hiển thị thời gian bên dưới thẻ
                                          style: TextStyle(fontSize: 25, color: Colors.white),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dự báo thời tiết 5 ngày tới',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(height: 10),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn bên trong SingleChildScrollView
                                shrinkWrap: true, // Để ListView hoạt động bên trong SingleChildScrollView
                                itemCount: fiveDayForecast.isNotEmpty ? fiveDayForecast.length : 1,
                                itemBuilder: (context, index) {
                                  if (fiveDayForecast.isEmpty) {
                                    return Center(child: Text('Không có dữ liệu dự báo', style: TextStyle(color: Colors.white)));
                                  }
                                  final forecast = fiveDayForecast[index];
                                  return Card(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          // Dòng đầu tiên: Hiển thị nhiệt độ
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${forecast["weekday"]} ${forecast["day"]}', // Nhiệt độ min - max
                                                style: TextStyle(fontSize: 22, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10), // Khoảng cách giữa hai dòng

                                          // Dòng thứ hai: Trạng thái, icon, độ ẩm, mưa
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Cột thứ nhất: Trạng thái thời tiết
                                              Flexible(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${forecast["tempMin"]}°C - ${forecast["tempMax"]}°C', // Ngày
                                                      style: TextStyle(fontSize: 18, color: Colors.white),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      '${forecast["condition"]}', // Trạng thái thời tiết
                                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              // Cột thứ hai: Icon thời tiết
                                              Flexible(
                                                flex: 2,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center, // Căn giữa cột
                                                  children: [
                                                    FaIcon(
                                                      _getWeatherIcon(forecast["icon"] as String),
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 20,),
                                              // Cột thứ ba: Độ ẩm và lượng mưa
                                              Flexible(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          Icons.opacity, // Icon cho độ ẩm
                                                          size: 20,
                                                          color: Colors.white,
                                                        ),

                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${forecast["humidity"]}%', // Độ ẩm
                                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          Icons.cloud, // Icon cho độ ẩm
                                                          size: 20,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${forecast["rain"]} mm', // Lượng mưa
                                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),



                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    // Ví dụ: bạn có thể sử dụng icon từ Font Awesome hoặc một bộ icon khác
    switch (iconCode) {
      case '01d':
        return FontAwesomeIcons.sun; // Nắng
      case '01n':
        return FontAwesomeIcons.moon; // Đêm
      case '02d':
      case '02n':
        return FontAwesomeIcons.cloudSun; // Mây nhẹ
      case '03d':
      case '03n':
        return FontAwesomeIcons.cloud; // Mây
      case '04d':
      case '04n':
        return FontAwesomeIcons.cloudMeatball; // Mây dày
      case '09d':
      case '09n':
        return FontAwesomeIcons.cloudShowersHeavy; // Mưa
      case '10d':
        return FontAwesomeIcons.cloudSunRain; // Mưa nhẹ
      case '11d':
        return FontAwesomeIcons.bolt; // Sấm sét
      case '13d':
        return FontAwesomeIcons.snowflake; // Tuyết
      case '50d':
      case '50n':
        return FontAwesomeIcons.smog; // Sương mù
      default:
        return FontAwesomeIcons.cloud; // Mặc định
    }
  }
  String _getWeatherImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/clear.png'; // Hình ảnh trời quang
      case 'smoke':
        return 'assets/mist.png';
      case 'haze':
        return 'assets/haze.png'; // Hình ảnh trời quang
      case 'sun':
        return 'assets/sun.png'; // Hình ảnh trời quang
      case 'clouds':
        return 'assets/clouds.png'; // Hình ảnh nhiều mây
      case 'rain':
        return 'assets/rain.png'; // Hình ảnh mưa
      case 'mist':
        return 'assets/heavycloud.png';
      case 'snow':
        return 'assets/snow.png'; // Hình ảnh tuyết
      case 'thunderstorm':
        return 'assets/thunderstorm.png'; // Hình ảnh bão
    // Thêm các trường hợp khác nếu cần
      default:
        return 'assets/default.png'; // Hình ảnh mặc định
    }
  }

  String _getWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'Bắc';
    if (degrees < 67.5) return 'Đông Bắc';
    if (degrees < 112.5) return 'Đông';
    if (degrees < 157.5) return 'Đông Nam';
    if (degrees < 202.5) return 'Nam';
    if (degrees < 247.5) return 'Tây Nam';
    if (degrees < 292.5) return 'Tây';
    return 'Tây Bắc';
  }
}
