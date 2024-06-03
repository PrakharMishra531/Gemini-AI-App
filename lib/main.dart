import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini/constants.dart';
import 'home_page.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        popupMenuTheme: PopupMenuThemeData(
          color: Color(0xFF1f1f1f), // Set the desired background color
        ),
      ),
      title: 'Gemini',
      home: HomePage(),
    );
  }
}
