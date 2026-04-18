import 'package:flutter/material.dart';

class Step6Success extends StatelessWidget {
  const Step6Success({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
          ),
          const SizedBox(height: 30),
          const Text(
            "Khách sạn đã được thêm thành công",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5AAC),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Xong", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}