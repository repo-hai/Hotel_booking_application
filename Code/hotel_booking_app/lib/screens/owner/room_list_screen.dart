import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room/room_type_model.dart';
import '../../models/room/room_model.dart';
import '../../providers/owner_provider.dart';

class RoomListScreen extends StatelessWidget {
  final RoomType roomType;
  const RoomListScreen({super.key, required this.roomType});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    // Tìm lại roomType trong provider để có dữ liệu mới nhất (nếu có cập nhật)
    final currentRoomType = provider.roomTypes.firstWhere(
      (rt) => rt.id.toString() == roomType.id.toString(), 
      orElse: () => roomType
    );
    final rooms = currentRoomType.rooms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Danh sách phòng - ${currentRoomType.name}", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
      ),
      body: rooms.isEmpty
          ? const Center(child: Text("Hạng phòng này chưa có danh sách phòng cụ thể."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                return _buildRoomItem(context, rooms[index], currentRoomType.id, currentRoomType.name);
              },
            ),
    );
  }

  Widget _buildRoomItem(BuildContext context, Room room, String roomTypeId, String roomTypeName) {
    final provider = Provider.of<OwnerProvider>(context, listen: false);

    // Map trạng thái sang màu sắc và văn bản hiển thị
    Color getStatusColor(String status) {
      switch (status) {
        case 'Available': return Colors.green;
        case 'Booked': return Colors.red;
        case 'Occupied': return Colors.orange;
        case 'Maintenance': return Colors.orange;
        default: return Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room_outlined, color: Colors.blueGrey),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phòng ${room.roomNumber}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  Text("Loại: $roomTypeName", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          
          // Dropdown để chọn trạng thái
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: getStatusColor(room.status).withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: ['Available', 'Booked', 'Occupied', 'Maintenance'].contains(room.status) ? room.status : 'Available',
                icon: Icon(Icons.keyboard_arrow_down, color: getStatusColor(room.status), size: 20),
                style: TextStyle(color: getStatusColor(room.status), fontWeight: FontWeight.bold, fontSize: 13),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    provider.updateRoomStatus(roomTypeId, room.id, newValue);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: 'Available',
                    child: Text('CÓ THỂ SỬ DỤNG'),
                  ),
                  DropdownMenuItem(
                    value: 'Booked',
                    child: Text('ĐÃ ĐƯỢC ĐẶT'),
                  ),
                  DropdownMenuItem(
                    value: 'Occupied',
                    child: Text('ĐANG SỬ DỤNG'),
                  ),
                  DropdownMenuItem(
                    value: 'Maintenance',
                    child: Text('ĐANG BẢO TRÌ'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}