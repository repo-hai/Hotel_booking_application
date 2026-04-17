import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import '../../../models/hotel/hotel_amenity_model.dart';

class Step2BasicInfo extends StatefulWidget {
  final VoidCallback onNext;
  const Step2BasicInfo({super.key, required this.onNext});

  @override
  State<Step2BasicInfo> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends State<Step2BasicInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final Set<String> _selectedAmenities = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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

  void _onNext() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    if (provider.draftHotel != null) {
      provider.draftHotel = Hotel(
        id: provider.draftHotel!.id,
        type: provider.draftHotel!.type,
        name: _nameController.text,
        description: _descController.text,
        telephone: _phoneController.text,
        location: provider.draftHotel!.location,
        email: _emailController.text,
        star: provider.draftHotel!.star,
        images: provider.draftHotel!.images,
        amenities: _selectedAmenities.map((a) => HotelAmenity(id: "", name: a, icon: "")).toList(),
      );
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput("Tên khách sạn *", _nameController),
                _buildInput("Mô tả khách sạn *", _descController, maxLines: 3),
                _buildInput("Số điện thoại *", _phoneController),
                _buildInput("Địa chỉ email *", _emailController),
                const Text("Tiện ích", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildCheckItem("Wifi miễn phí"),
                _buildCheckItem("Phòng gym"),
                _buildCheckItem("Hồ bơi"),
                _buildCheckItem("Quầy bar"),
                _buildCheckItem("Spa"),
              ],
            ),
          ),
        ),
        _buildBottomButton(_onNext),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    bool isRequired = label.contains('*');
    String cleanLabel = label.replaceAll('*', '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: cleanLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCheckItem(String title) {
    bool isSelected = _selectedAmenities.contains(title);
    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      selected: isSelected,
      activeColor: const Color(0xFF2E5AAC),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (v) => _toggleAmenity(title),
    );
  }

  Widget _buildBottomButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5AAC),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}