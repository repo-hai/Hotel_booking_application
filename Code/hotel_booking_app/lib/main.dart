import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/owner_provider.dart';
import 'screens/owner/owner_home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OwnerProvider()),
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
      title: 'Hotel Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OwnerHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}