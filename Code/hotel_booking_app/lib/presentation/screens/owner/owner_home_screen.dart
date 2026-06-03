import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import '../../widgets/network_image_with_placeholder.dart';
import 'edit_hotel_master.dart';
import 'add_hotel/add_hotel_master.dart'; 
import 'hotel_detail_screen_giang.dart';
import 'statistics_home_screen.dart';
import 'owner_account_screen.dart';
import '../profile_view3.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProvider>(context, listen: false).refreshDashboard();
    });
  }

  void _confirmDelete(Hotel hotel) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, color: Colors.pink, size: 80),
              const SizedBox(height: 20),
              Text(
                "Bạn có chắc chắn\nmuốn xóa ${hotel.name} không?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.pink),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Hủy", style: TextStyle(color: Colors.pink)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final provider = Provider.of<OwnerProvider>(context, listen: false);
                        await provider.deleteHotel(hotel.id);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5AAC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final hotels = provider.hotels;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.refreshDashboard(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text("Khách sạn bạn đang quản lý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              provider.isLoading && hotels.isEmpty
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  : hotels.isEmpty
                      ? const SliverFillRemaining(child: Center(child: Text("Bạn chưa có khách sạn nào.")))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: _buildHotelItem(hotels[index]),
                            ),
                            childCount: hotels.length,
                          ),
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final provider = Provider.of<OwnerProvider>(context, listen: false);
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHotelMasterScreen()));
          if (mounted) provider.refreshDashboard();
        },
        backgroundColor: const Color(0xFF2E5AAC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25, 
            backgroundColor: Color(0xFF2E5AAC),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chào chủ khách sạn! 👋", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Consumer<OwnerProvider>(
                  builder: (context, provider, child) {
                    return Text(provider.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
                  },
                ),
              ],
            ),
          ),
          _iconAction(Icons.search),
          const SizedBox(width: 10),
          _iconAction(Icons.notifications_none),
        ],
      ),
    );
  }


  Widget _iconAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 22),
    );
  }

  Widget _buildHotelItem(Hotel hotel) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
      child: Container(
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
                      Expanded(child: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(" ${hotel.star}.0")]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit_note, color: Color(0xFF2E5AAC)),
                        onPressed: () async {
                          final provider = Provider.of<OwnerProvider>(context, listen: false);
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => EditHotelScreen(hotel: hotel)));
                          if (mounted) provider.refreshDashboard();
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.delete_outline, color: Colors.pink),
                        onPressed: () => _confirmDelete(hotel),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E5AAC),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsHomeScreen()));
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
}