import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/owner_provider.dart';
import '../../../../models/hotel/hotel_model.dart';

class Step4ManualLocation extends StatefulWidget {
  final VoidCallback onNext;
  const Step4ManualLocation({super.key, required this.onNext});

  @override
  State<Step4ManualLocation> createState() => _Step4ManualLocationState();
}

class _Step4ManualLocationState extends State<Step4ManualLocation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    if (provider.draftHotel != null) {
      final loc = "${_addressController.text}, ${_wardController.text}, ${_districtController.text}, ${_cityController.text}";
      provider.draftHotel = Hotel(
        id: provider.draftHotel!.id,
        type: provider.draftHotel!.type,
        name: provider.draftHotel!.name,
        description: provider.draftHotel!.description,
        telephone: provider.draftHotel!.telephone,
        location: loc,
        email: provider.draftHotel!.email,
        star: provider.draftHotel!.star,
        images: provider.draftHotel!.images,
        amenities: provider.draftHotel!.amenities,
      );
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin vị trí",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationField("Tỉnh/Thành phố *", _cityController, validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập Tỉnh/Thành phố' : null),
                  _buildLocationField("Quận/Huyện *", _districtController, validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập Quận/Huyện' : null),
                  _buildLocationField("Phường/Xã *", _wardController, validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập Phường/Xã' : null),
                  _buildLocationField("Địa chỉ cụ thể *", _addressController, validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập địa chỉ cụ thể' : null),
                ],
              ),
            ),
          ),
          _buildBottomButton(_onNext),
        ],
      ),
    );
  }

  Widget _buildLocationField(String label, TextEditingController controller, {String? Function(String?)? validator}) {
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
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
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