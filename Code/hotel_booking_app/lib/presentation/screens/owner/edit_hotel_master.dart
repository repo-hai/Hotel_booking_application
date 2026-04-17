import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import '../../../models/hotel/hotel_image_model.dart';
import '../../../models/hotel/hotel_amenity_model.dart';

class EditHotelScreen extends StatefulWidget {
  final Hotel hotel;
  const EditHotelScreen({super.key, required this.hotel});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _wardController;
  late TextEditingController _addressController;

  final Set<String> _selectedAmenities = {};
  List<HotelImage> _existingImages = [];
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Khởi tạo tab Cơ bản
    _nameController = TextEditingController(text: widget.hotel.name);
    _descController = TextEditingController(text: widget.hotel.description);
    _phoneController = TextEditingController(text: widget.hotel.telephone);
    _emailController = TextEditingController(text: widget.hotel.email);
    for (var a in widget.hotel.amenities) {
      _selectedAmenities.add(a.name);
    }

    // Khởi tạo tab Vị trí - Parse chuỗi location "Địa chỉ, Phường, Quận, Thành phố"
    List<String> locParts = widget.hotel.location.split(', ');
    _addressController = TextEditingController(text: locParts.isNotEmpty ? locParts[0] : "");
    _wardController = TextEditingController(text: locParts.length > 1 ? locParts[1] : "");
    _districtController = TextEditingController(text: locParts.length > 2 ? locParts[2] : "");
    _cityController = TextEditingController(text: locParts.length > 3 ? locParts.sublist(3).join(', ') : "");

    // Khởi tạo tab Ảnh
    _existingImages = List.from(widget.hotel.images);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.check, color: Colors.green, size: 50),
                ),
                const SizedBox(height: 20),
                const Text("Thành công", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "Thông tin đã được chỉnh sửa\nthành công",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng popup
                    Navigator.pop(context); // Quay về Home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5AAC),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Ok", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi ảnh: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSaving
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text("Sửa thông tin", style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E5AAC),
          indicatorColor: const Color(0xFF2E5AAC),
          tabs: const [Tab(text: "Cơ bản"), Tab(text: "Vị trí"), Tab(text: "Ảnh")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicTab(),
          _buildLocationTab(),
          _buildImageTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E5AAC),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : () async {
            setState(() => _isSaving = true);
            final provider = Provider.of<OwnerProvider>(context, listen: false);

            // Xử lý hình ảnh trước (Upload Server nếu có)
            List<HotelImage> finalImgs = List.from(_existingImages);
            for (var xfile in _selectedImages) {
              String? url = await provider.uploadImage(xfile);
              if (url != null) {
                finalImgs.add(HotelImage(id: "", url: url));
              }
            }

            // Xử lý Vị trí
            final loc = "${_addressController.text}, ${_wardController.text}, ${_districtController.text}, ${_cityController.text}";
            
            // Xử lý Amenities
            final ams = _selectedAmenities.map((a) => HotelAmenity(id: "", name: a, icon: "")).toList();

            final updatedHotel = Hotel(
              id: widget.hotel.id,
              type: widget.hotel.type,
              name: _nameController.text,
              description: _descController.text,
              telephone: _phoneController.text,
              location: loc,
              email: _emailController.text,
              star: widget.hotel.star,
              images: finalImgs,
              amenities: ams,
            );
            
            bool success = await provider.updateHotel(updatedHotel);
            
            if (mounted) {
              setState(() => _isSaving = false);
              if (success) {
                _showSuccessPopup();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi cập nhật. Vui lòng thử lại.')));
              }
            }
          },
          child: _isSaving 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  // ============== TABS ==============

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInput("Tên khách sạn *", _nameController),
          _buildInput("Mô tả khách sạn *", _descController, maxLines: 3),
          _buildInput("Số điện thoại *", _phoneController),
          _buildInput("Địa chỉ email *", _emailController),
          
          const SizedBox(height: 10),
          const Text("Tiện ích", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildCheckItem("Wifi miễn phí"),
          _buildCheckItem("Phòng gym"),
          _buildCheckItem("Hồ bơi"),
          _buildCheckItem("Quầy bar"),
          _buildCheckItem("Spa"),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInput("Tỉnh/Thành phố *", _cityController),
          _buildInput("Quận/Huyện *", _districtController),
          _buildInput("Phường/Xã *", _wardController),
          _buildInput("Địa chỉ cụ thể *", _addressController),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vui lòng tải lên hình ảnh hồ sơ khách sạn của bạn để khách hàng có thể xem rõ hơn!", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._existingImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imgUrl = entry.value.url;
                    return Stack(
                      children: [
                        Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                          ),
                        ),
                        if (!_isSaving)
                          Positioned(
                            top: 6, right: 6,
                            child: GestureDetector(
                              onTap: () => setState(() => _existingImages.removeAt(index)),
                              child: Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.remove, color: Colors.blueAccent, size: 20),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  ..._selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final xfile = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: kIsWeb ? NetworkImage(xfile.path) as ImageProvider : FileImage(File(xfile.path)), 
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                        if (!_isSaving)
                          Positioned(
                            top: 6, right: 6,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImages.removeAt(index)),
                              child: Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.remove, color: Colors.red, size: 20),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  if (!_isSaving)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.black54, size: 32),
                            SizedBox(height: 4),
                            Text("Thêm ảnh", style: TextStyle(color: Colors.black45, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
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
      onChanged: (v) {
        setState(() {
          if (isSelected) {
            _selectedAmenities.remove(title);
          } else {
            _selectedAmenities.add(title);
          }
        });
      },
      contentPadding: EdgeInsets.zero,
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
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}