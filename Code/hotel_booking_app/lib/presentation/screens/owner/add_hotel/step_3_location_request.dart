import 'package:flutter/material.dart';

class Step3LocationRequest extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onManual;

  const Step3LocationRequest({
    super.key, 
    required this.onNext, 
    required this.onManual
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon vị trí lớn ở giữa
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, size: 80, color: Color(0xFF2E5AAC)),
          ),
          const SizedBox(height: 40),
          const Text(
            "Cho phép truy cập vị trí",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "Vui lòng bật quyền truy cập vị trí để xác định vị trí khách sạn.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5AAC),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onNext,
            child: const Text("Cho phép", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: onManual,
            child: const Text("Nhập thủ công", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}