import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../models/room/room_model.dart';
import 'price_calendar_screen.dart';
import 'add_room_step3_screen.dart';

class AddRoomStep2Screen extends StatefulWidget {
  const AddRoomStep2Screen({super.key});

  @override
  State<AddRoomStep2Screen> createState() => _AddRoomStep2ScreenState();
}

class _AddRoomStep2ScreenState extends State<AddRoomStep2Screen> {
  late TextEditingController _priceController;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  
  int _currentPrice = 0;
  String _selectedPolicy = "Không thể hoàn trả";

  @override
  void initState() {
    super.initState();
    _currentPrice = 0;
    _priceController = TextEditingController(text: "0 VND");
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PriceCalendarScreen(initialPrice: _currentPrice)),
    );

    if (result != null && result is int) {
      setState(() {
        _currentPrice = result;
        _priceController.text = "${NumberFormat("#,###").format(_currentPrice)} VND";
      });
    }
  }

  void _saveAndNext() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    if (provider.draftRoomType != null) {
      // Logic tự động sinh danh sách phòng từ chuỗi nhập vào
      List<String> roomNames = _roomsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<Room> generatedRooms = roomNames.map((name) {
        return Room(
          id: DateTime.now().millisecondsSinceEpoch.toString() + name, // Tạm thời tạo ID duy nhất
          roomNumber: name,
          status: 'Available',
        );
      }).toList();

      provider.draftRoomType = provider.draftRoomType!.copyWith(
        price: _currentPrice,
        description: _descController.text,
        rooms: generatedRooms,
        cancellationPolicy: _selectedPolicy,
      );
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomStep3Screen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thông tin phòng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              const TextSpan(
                children: [
                   TextSpan(text: "Giá phòng", style: TextStyle(fontWeight: FontWeight.bold)),
                   TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black),
                  onPressed: _openCalendar,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildInput("Mô tả phòng *", "Nhập mô tả chi tiết", _descController),
            
            const Text("Chính sách hoàn trả *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDropdown(),
            
            const SizedBox(height: 20),
            _buildInput("Danh sách phòng *", "VD: P101, P102, P103", _roomsController),
            const Text("ℹ Nhập danh sách phòng, cách nhau bằng dấu \",\"", style: TextStyle(fontSize: 11, color: Colors.grey)),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5AAC),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String hint, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 15),
    ]);
  }

  Widget _buildDropdown() {
    final List<String> options = [
      "Không thể hoàn trả",
      "Hoàn 50% trước 24h",
      "Hoàn 100% trước 24h",
      "Hoàn 100% trước 48h",
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedPolicy,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedPolicy = v;
              });
            }
          },
        ),
      ),
    );
  }
}