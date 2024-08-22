import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Loading dotenv...');
  await dotenv.load(fileName: "assets/.env");
  print('Dotenv loaded');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 2, 117, 240)),
        useMaterial3: true,
      ),
      home: WeatherScreen(),
    );
  }
}
