import 'package:flutter/material.dart';
import 'package:p_sosyo/app/views/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PSosyo',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const LandingPage(),
    );
  }
}
