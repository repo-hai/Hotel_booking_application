import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/room/room_image_model.dart';
import 'add_room_step4_screen.dart';

class AddRoomStep3Screen extends StatefulWidget {
  const AddRoomStep3Screen({super.key});

  @override
  State<AddRoomStep3Screen> createState() => _AddRoomStep3ScreenState();
}

class _AddRoomStep3ScreenState extends State<AddRoomStep3Screen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false; // Trạng thái màn hình khóa khi đang upload

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitAndNext() async {
    setState(() {
      _isUploading = true;
    });

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    List<RoomImage> uploadedImgs = [];
    final List<String> uploadErrors = [];

    // Upload từng ảnh lên Express server
    for (int i = 0; i < _selectedImages.length; i++) {
      final xfile = _selectedImages[i];
      String? url = await provider.uploadImage(xfile);
      if (url != null) {
        uploadedImgs.add(RoomImage(id: '', url: url));
      } else {
        final err = provider.lastUploadError ?? 'Không rõ lỗi';
        uploadErrors.add('Ảnh ${i + 1}: $err');
      }
    }

    // Cảnh báo ảnh upload lỗi
    if (uploadErrors.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Một số ảnh không upload được:\n${uploadErrors.join('\n')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (provider.draftRoomType != null) {
      provider.draftRoomType = provider.draftRoomType!.copyWith(images: uploadedImgs);
      // Gọi lên Backend tạo dữ liệu mới
      bool success = await provider.createRoomType(provider.draftRoomType!);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        if (success) {
          provider.draftRoomType = null;
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomStep4Screen()));
        } else {
          final errMsg = provider.lastCreateRoomError ?? 'Lỗi không xác định từ server';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tạo hạng phòng: $errMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi dữ liệu hệ thống (Form trống)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _selectedImages.isNotEmpty && !_isUploading;

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
                    // Hiển thị các ảnh đã chọn với nút "-" để xóa
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
                          // Nút "-" xóa ảnh đang hiện nếu chưa upload
                          if (!_isUploading)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, color: Colors.red, size: 20),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    // Nút "+" chọn ảnh từ máy tính
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
            // Nút Xong
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasImage ? _submitAndNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasImage ? const Color(0xFF2E5AAC) : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
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