import 'package:flutter/material.dart';
import 'presentation/screens/booking_home_screen.dart';

void main() {
  runApp(const HotelBookingApp());
}

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003580)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const BookingHomeScreen(),
    );
  }
}
