import 'package:flutter/material.dart';
import 'package:hotel_booking_app/models/payment/payment_model.dart';
import 'package:hotel_booking_app/presentation/screens/payment_view.dart';
import 'package:hotel_booking_app/presentation/screens/view_comment_rating.dart';
import 'package:provider/provider.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: false,
      home: Material(
        child: PaymentView(),
      ),
    );
  }
}