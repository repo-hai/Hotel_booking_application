import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/admin/admin_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AdminMainScreen(),
    );
  }
}
