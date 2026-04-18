import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_booking_app/presentation/screens/owner/owner_home_screen.dart';
import 'package:hotel_booking_app/providers/owner_provider.dart';
import 'package:hotel_booking_app/presentation/screens/login.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}