import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../models/room/room_type_model.dart';
import '../../models/room/room_amenity_model.dart';
import 'add_room_step1_screen.dart';
import 'edit_room_step1_screen.dart';
import 'room_list_screen.dart';
import '../../models/hotel/hotel_model.dart';

class AllRoomTypesScreen extends StatefulWidget {
  final String? hotelId;
  const AllRoomTypesScreen({super.key, this.hotelId});

  @override
  State<AllRoomTypesScreen> createState() => _AllRoomTypesScreenState();
}

class _AllRoomTypesScreenState extends State<AllRoomTypesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final hId = widget.hotelId ?? (provider.hotels.isNotEmpty ? provider.hotels[0].id : "");
    if (hId.isNotEmpty) {
      provider.fetchHotelDetails(hId);
    }
  }

  void _showDeleteConfirmation(BuildContext context, RoomType rt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.pink, width: 4)),
                  child: const Icon(Icons.help_outline, color: Colors.pink, size: 60),
                ),
                const SizedBox(height: 25),
                Text("Xóa loại phòng\n${rt.name}?", textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.pink), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Hủy", style: TextStyle(color: Colors.pink)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final provider = Provider.of<OwnerProvider>(context, listen: false);
                          provider.deleteRoomType(rt.id);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E5AAC), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final roomTypes = provider.roomTypes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Loại phòng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading && roomTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: roomTypes.isEmpty
                  ? const Center(child: Text("Chưa có loại phòng nào"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: roomTypes.length,
                      itemBuilder: (context, index) => _buildRoomTypeCard(context, roomTypes[index]),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E5AAC),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomStep1Screen())),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildRoomTypeCard(BuildContext context, RoomType rt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(rt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomListScreen(roomType: rt))),
                child: const Text("Chi tiết phòng >", style: TextStyle(color: Color(0xFF2E5AAC), fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Area and Capacity
                    Row(
                      children: [
                        const Icon(Icons.straighten, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${rt.area} m²", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(width: 15),
                        const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${rt.capacity} người", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Cancellation Policy Chip
                    _buildPolicyChip(rt.cancellationPolicy),
                    const SizedBox(height: 10),

                    // Amenities Row (Icons)
                    _buildAmenitiesIcons(rt.amenities),
                    const SizedBox(height: 12),

                    Text("${NumberFormat.decimalPattern('en_US').format(rt.price)} VND", style: const TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    rt.images.isNotEmpty ? rt.images[0].url : 'https://via.placeholder.com/150',
                    height: 100, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.hotel, size: 40)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditRoomStep1Screen(roomTypeId: rt.id)));
                    _fetchData();
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF2E5AAC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text("Sửa", style: TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeleteConfirmation(context, rt),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.pink), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text("Xóa", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyChip(String policy) {
    Color color;
    if (policy.contains("100%")) {
      color = Colors.green;
    } else if (policy.contains("50%")) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        policy,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAmenitiesIcons(List<RoomAmenity> amenities) {
    // Map tên tiện ích sang Icon
    IconData getIcon(String name) {
      final n = name.toLowerCase();
      if (n.contains("wifi")) return Icons.wifi;
      if (n.contains("ac") || n.contains("máy lạnh") || n.contains("điều hòa")) return Icons.ac_unit;
      if (n.contains("tv") || n.contains("tivi")) return Icons.tv;
      if (n.contains("bếp") || n.contains("kitchen")) return Icons.kitchen;
      if (n.contains("tắm") || n.contains("bath")) return Icons.bathtub_outlined;
      if (n.contains("ban công") || n.contains("balcony")) return Icons.balcony;
      return Icons.check_circle_outline;
    }

    // Chỉ hiển thị tối đa 5 tiện ích để tránh tràn hàng
    final displayed = amenities.take(5).toList();

    return Wrap(
      spacing: 8,
      children: displayed.map((a) => Icon(getIcon(a.name), size: 16, color: Colors.blueGrey)).toList(),
    );
  }
}