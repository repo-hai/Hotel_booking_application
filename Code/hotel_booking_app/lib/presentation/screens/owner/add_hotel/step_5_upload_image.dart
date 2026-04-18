import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../providers/owner_provider.dart';
import '../../../../models/hotel/hotel_image_model.dart';
import '../../../../models/hotel/hotel_model.dart';

class Step5UploadImage extends StatefulWidget {
  final VoidCallback onNext;
  const Step5UploadImage({super.key, required this.onNext});

  @override
  State<Step5UploadImage> createState() => _Step5UploadImageState();
}

class _Step5UploadImageState extends State<Step5UploadImage> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitAndCreateHotel() async {
    setState(() => _isUploading = true);

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    List<HotelImage> finalImgs = [];
    final List<String> uploadErrors = [];

    // Tải ảnh lên Server Nodejs
    for (int i = 0; i < _selectedImages.length; i++) {
      final xfile = _selectedImages[i];
      String? url = await provider.uploadImage(xfile);
      if (url != null) {
        finalImgs.add(HotelImage(id: '', url: url));
      } else {
        final err = provider.lastUploadError ?? 'Không rõ lỗi';
        uploadErrors.add('Ảnh ${i + 1}: $err');
      }
    }

    // Cảnh báo nếu có ảnh upload lỗi nhưng không dừng lại
    if (uploadErrors.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Một số ảnh không upload được:\n${uploadErrors.join('\n')}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (provider.draftHotel != null) {
      provider.draftHotel = Hotel(
        id: provider.draftHotel!.id,
        type: provider.draftHotel!.type,
        name: provider.draftHotel!.name,
        description: provider.draftHotel!.description,
        telephone: provider.draftHotel!.telephone,
        location: provider.draftHotel!.location,
        email: provider.draftHotel!.email,
        star: provider.draftHotel!.star,
        images: finalImgs,
        amenities: provider.draftHotel!.amenities,
      );

      bool success = await provider.createHotel();

      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          provider.draftHotel = null;
          widget.onNext();
        } else {
          final errMsg = provider.lastCreateError ?? 'Lỗi không xác định từ server';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tạo khách sạn: $errMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ảnh khách sạn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Vui lòng tải lên hình ảnh hồ sơ khách sạn của bạn để khách hàng có thể xem rõ hơn!", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
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
                                    fit: BoxFit.cover
                                  ),
                                ),
                              ),
                              if (!_isUploading)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
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
                        if (!_isUploading)
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
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedImages.isNotEmpty ? const Color(0xFF2E5AAC) : Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: _isUploading ? null : (_selectedImages.isNotEmpty ? _submitAndCreateHotel : null),
        child: _isUploading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Xong", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}