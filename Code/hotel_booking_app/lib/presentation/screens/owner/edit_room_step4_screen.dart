import 'package:flutter/material.dart';

class EditRoomStep4Screen extends StatelessWidget {
  const EditRoomStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Quay về màn hình danh sách hạng phòng
            Navigator.of(context).popUntil((route) => route.settings.name == 'AllRoomTypesScreen');
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon tích xanh thành công
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF66BB6A),
                size: 80,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Phòng đã được sửa\nthành công",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E5AAC),
        onTap: (index) {
          Navigator.of(context).popUntil((route) => route.settings.name == 'AllRoomTypesScreen');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Thống kê"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Tin nhắn"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
        ],
      ),
    );
  }
}