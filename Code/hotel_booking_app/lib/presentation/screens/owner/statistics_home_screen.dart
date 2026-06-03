import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import '../../widgets/network_image_with_placeholder.dart';
import 'statistics_screen.dart';
import 'owner_account_screen.dart';
import 'owner_home_screen.dart';
import '../profile_view3.dart';

class StatisticsHomeScreen extends StatefulWidget {
  const StatisticsHomeScreen({super.key});

  @override
  State<StatisticsHomeScreen> createState() => _StatisticsHomeScreenState();
}

class _StatisticsHomeScreenState extends State<StatisticsHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProvider>(context, listen: false).refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final hotels = provider.hotels;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Chọn khách sạn xem thống kê", 
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: provider.isLoading && hotels.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refreshDashboard(),
              child: hotels.isEmpty
                  ? const Center(child: Text("Bạn chưa có khách sạn nào."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: hotels.length,
                      itemBuilder: (context, index) => _buildHotelItem(context, hotels[index]),
                    ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E5AAC),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
            (route) => false,
          );
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView(isOwner: true)));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Thống kê"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Tin nhắn"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }

  Widget _buildHotelItem(BuildContext context, Hotel hotel) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StatisticsScreen(hotel: hotel)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            NetworkImageWithPlaceholder(
              url: hotel.images.isNotEmpty ? hotel.images[0].url : null,
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(12),
              placeholderIcon: Icons.hotel,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(" ${hotel.star}.0", style: const TextStyle(fontWeight: FontWeight.bold))]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      Expanded(child: Text(" ${hotel.location}", style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}