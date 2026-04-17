import 'package:flutter/material.dart';
import 'package:hotel_booking_app/presentation/screens/admin/admin_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdminMainScreen(),
    );
  }
}