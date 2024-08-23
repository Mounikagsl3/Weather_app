import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = "";
  String apiKey = dotenv.env['API_KEY'] ?? '';
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? forecastData;

  Future<void> fetchWeather() async {
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    try {
      // Fetch Current Weather
      final currentWeatherUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey');
      final currentWeatherResponse = await http.get(currentWeatherUrl);

      // Fetch 5-Day Forecast
      final forecastUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey');
      final forecastResponse = await http.get(forecastUrl);

      if (currentWeatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        setState(() {
          currentWeatherData = json.decode(currentWeatherResponse.body);
          forecastData = json.decode(forecastResponse.body);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Enter City'),
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchWeather,
              child: Text('Get Weather'),
            ),
            SizedBox(height: 20),
            if (currentWeatherData != null)
              Column(
                children: [
                  Text(
                    'Temperature: ${currentWeatherData!['main']['temp']}°C',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Condition: ${currentWeatherData!['weather'][0]['description']}',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            if (forecastData != null)
              Expanded(
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, 
      childAspectRatio: 3, 
    ),
    itemCount: (forecastData!['list'] as List).length,
    itemBuilder: (context, index) {
      final forecast = forecastData!['list'][index];
      final dateTime = DateTime.parse(forecast['dt_txt']);
      final temp = forecast['main']['temp'];

      // Determine the color based on the temperature
      Color tempColor;
      if (temp < 30) {
        tempColor = Colors.blue; // Cold
      } else if (temp >= 30 && temp <= 35) {
        tempColor = Colors.orange; // Warm
      } else {
        tempColor = Colors.red; // Hot
      }

      return Card(
        margin: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:00',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '${temp}°C',
              style: TextStyle(
                fontSize: 16.0,
                color: tempColor,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              '${forecast['weather'][0]['description']}',
     ),
       ],
     ),
         );
    },
  ),
),

          ],
  ),
    ),
    );
     }
  }
