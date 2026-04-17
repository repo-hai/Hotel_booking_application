import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../models/room/room_image_model.dart';
import 'edit_room_step4_screen.dart';

class EditRoomStep3Screen extends StatefulWidget {
  final String? roomTypeId;
  const EditRoomStep3Screen({super.key, this.roomTypeId});

  @override
  State<EditRoomStep3Screen> createState() => _EditRoomStep3ScreenState();
}

class _EditRoomStep3ScreenState extends State<EditRoomStep3Screen> {
  List<RoomImage> _existingImages = [];
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
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
      final currentRt = provider.roomTypes.firstWhere((r) => r.id == rId, orElse: () => provider.roomTypes[0]);
      setState(() {
        _existingImages = List.from(currentRt.images);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitAndNext() async {
    setState(() => _isUploading = true);

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    List<RoomImage> finalImgs = List.from(_existingImages);

    // Upload từng ảnh mới
    for (var xfile in _selectedImages) {
      String? url = await provider.uploadImage(xfile);
      if (url != null) {
        finalImgs.add(RoomImage(id: "", url: url));
      }
    }

    final rId = widget.roomTypeId ?? (provider.roomTypes.isNotEmpty ? provider.roomTypes[0].id : "");
    if (rId.isNotEmpty) {
      final currentRt = provider.roomTypes.firstWhere((r) => r.id == rId);
      final updatedRt = currentRt.copyWith(images: finalImgs);
      
      bool success = await provider.updateRoomType(updatedRt);
      
      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditRoomStep4Screen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật hạng phòng!")));
        }
      }
    } else {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi không tìm thấy phòng!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isUploading
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text("Ảnh phòng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng tải lên hình ảnh phòng của bạn để khách hàng có thể xem rõ hơn!",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // --- Ảnh Hiện Tại (đã có từ API) ---
                    ..._existingImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imgUrl = entry.value.url;
                      return Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(imgUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(index),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.remove, color: Colors.blueAccent, size: 20),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    
                    // --- Ảnh Mới Pick Từ Máy ---
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final xfile = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: kIsWeb ? NetworkImage(xfile.path) as ImageProvider : FileImage(File(xfile.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (!_isUploading)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeNewImage(index),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: const Icon(Icons.remove, color: Colors.red, size: 20),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    
                    if (!_isUploading)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitAndNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5AAC),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isUploading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Xong", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}