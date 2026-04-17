import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../models/room/room_amenity_model.dart';
import 'edit_room_step2_screen.dart';

class EditRoomStep1Screen extends StatefulWidget {
  final String? roomTypeId;
  const EditRoomStep1Screen({super.key, this.roomTypeId});

  @override
  State<EditRoomStep1Screen> createState() => _EditRoomStep1ScreenState();
}

class _EditRoomStep1ScreenState extends State<EditRoomStep1Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedTypeController = TextEditingController();
  final TextEditingController _bedCountController = TextEditingController();

  Set<String> _selectedAmenities = {};
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadInitialData();
      _isInitialized = true;
    }
  }

  void _loadInitialData() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final rId = widget.roomTypeId ?? (provider.roomTypes.isNotEmpty ? provider.roomTypes[0].id : "");
    if (rId.isNotEmpty) {
      final rt = provider.roomTypes.firstWhere((r) => r.id == rId, orElse: () => provider.roomTypes[0]);
      _nameController.text = rt.name;
      _capacityController.text = rt.capacity.toString();
      _sizeController.text = rt.area.toString();
      _bedTypeController.text = rt.bedType;
      _bedCountController.text = rt.bedNum.toString();
      _selectedAmenities = rt.amenities.map((e) => e.name).toSet();
    }
  }

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
    final rId = widget.roomTypeId ?? (provider.roomTypes.isNotEmpty ? provider.roomTypes[0].id : "");
    
    if (rId.isNotEmpty) {
      final currentRt = provider.roomTypes.firstWhere((r) => r.id == rId);
      final updatedRt = currentRt.copyWith(
        name: _nameController.text,
        capacity: int.tryParse(_capacityController.text) ?? currentRt.capacity,
        area: double.tryParse(_sizeController.text) ?? currentRt.area,
        bedType: _bedTypeController.text,
        bedNum: int.tryParse(_bedCountController.text) ?? currentRt.bedNum,
        amenities: _selectedAmenities.map((name) => RoomAmenity(id: "", name: name, icon: "")).toList(),
      );
      
      provider.updateRoomType(updatedRt);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => EditRoomStep2Screen(roomTypeId: rId)));
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
            _buildField("Tên loại phòng *", _nameController, "Nhập tên"),
            _buildField("Sức chứa tối đa *", _capacityController, "người lớn", isSuffix: true),
            _buildField("Diện tích phòng *", _sizeController, "m²", isSuffix: true),
            _buildField("Loại giường *", _bedTypeController, "Nhập loại giường"),
            _buildField("Số lượng giường *", _bedCountController, "Nhập số lượng"),
            const SizedBox(height: 20),
            const Text("Tiện ích", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...["Chống âm", "Phòng tắm riêng", "Điều hòa", "Bữa sáng miễn phí", "Bữa trưa miễn phí", "Wifi miễn phí"].map((e) => _buildCheck(e)),
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
          backgroundColor: const Color(0xFF2E5AAC),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}