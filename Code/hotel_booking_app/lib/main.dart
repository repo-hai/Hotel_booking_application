import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_booking_app/providers/owner_provider.dart';
import 'package:hotel_booking_app/presentation/screens/login.dart';

// Định nghĩa hàm main cho ứng dụng
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OwnerProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Giao diện chính khi khởi động ứng dụng - gọi tới giao diện login
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: false,
      home: Material(
        child: Login(),
      ),
    );
  }
}