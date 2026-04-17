import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../models/room/room_type_model.dart';
import '../../models/room/room_amenity_model.dart';
import 'add_room_step2_screen.dart';

class AddRoomStep1Screen extends StatefulWidget {
  final String? hotelId;
  const AddRoomStep1Screen({super.key, this.hotelId});

  @override
  State<AddRoomStep1Screen> createState() => _AddRoomStep1ScreenState();
}

class _AddRoomStep1ScreenState extends State<AddRoomStep1Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedTypeController = TextEditingController();
  final TextEditingController _bedCountController = TextEditingController();

  final Set<String> _selectedAmenities = {};

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _sizeController.dispose();
    _bedTypeController.dispose();
    _bedCountController.dispose();
    super.dispose();
  }

  void _toggleAmenity(String title) {
    setState(() {
      if (_selectedAmenities.contains(title)) {
        _selectedAmenities.remove(title);
      } else {
        _selectedAmenities.add(title);
      }
    });
  }

  void _saveAndNext() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    String hId = widget.hotelId ?? (provider.hotels.isNotEmpty ? provider.hotels[0].id : "demo_hotel");
    
    provider.draftRoomType = RoomType(
      id: "",
      hotelId: hId,
      name: _nameController.text.isNotEmpty ? _nameController.text : "Chưa đặt tên",
      price: 0,
      capacity: int.tryParse(_capacityController.text) ?? 1,
      area: double.tryParse(_sizeController.text) ?? 0,
      description: "",
      bedType: _bedTypeController.text,
      bedNum: int.tryParse(_bedCountController.text) ?? 1,
      amenities: _selectedAmenities.map((a) => RoomAmenity(id: "", name: a, icon: "")).toList(),
      images: [],
    );

    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomStep2Screen()));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Tên loại phòng *", _nameController, "Nhập tên loại phòng"),
            _buildField("Sức chứa tối đa *", _capacityController, "người lớn", isSuffix: true),
            _buildField("Diện tích phòng *", _sizeController, "m²", isSuffix: true),
            _buildField("Loại giường *", _bedTypeController, "Nhập loại giường"),
            _buildField("Số lượng giường *", _bedCountController, "Nhập số lượng"),
            const SizedBox(height: 20),
            const Text("Tiện ích", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...["Chống âm", "Phòng tắm riêng", "Điều hòa", "Bữa sáng miễn phí", "Wifi miễn phí"].map((e) => _buildCheck(e)),
            const SizedBox(height: 30),
            _buildNextBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {bool isSuffix = false}) {
    bool isRequired = label.contains('*');
    String cleanLabel = label.replaceAll('*', '').trim();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(text: cleanLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixText: isSuffix ? hint : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 15),
    ]);
  }

  Widget _buildCheck(String title) {
    bool isSelected = _selectedAmenities.contains(title);
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: isSelected,
      onChanged: (v) => _toggleAmenity(title),
      activeColor: const Color(0xFF2E5AAC),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildNextBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveAndNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5AAC), // Màu xanh theo thiết kế
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}