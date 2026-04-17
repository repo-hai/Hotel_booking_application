import 'package:flutter/material.dart';
import 'package:hotel_booking_app/widgets/login.dart';
import 'package:hotel_booking_app/widgets/register.dart';
import 'package:hotel_booking_app/widgets/view_comment_rating.dart';
import 'package:hotel_booking_app/widgets/list_chatbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}