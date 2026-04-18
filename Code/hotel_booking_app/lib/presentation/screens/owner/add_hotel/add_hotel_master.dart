import 'package:flutter/material.dart';
import 'step_1_type_selection.dart';
import 'step_2_basic_info.dart';
import 'step_3_location_request.dart';
import 'step_4_manual_location.dart';
import 'step_5_upload_image.dart';
import 'step_6_success.dart';

class AddHotelMasterScreen extends StatefulWidget {
  const AddHotelMasterScreen({super.key});

  @override
  State<AddHotelMasterScreen> createState() => _AddHotelMasterScreenState();
}

class _AddHotelMasterScreenState extends State<AddHotelMasterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentPage == 5 ? null : AppBar(
        title: Text(_currentPage == 0 ? "Chọn loại hình cơ sở" : "Thêm khách sạn"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Chặn vuốt tay để bắt buộc nhấn nút
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          Step1TypeSelection(onNext: _nextPage),
          Step2BasicInfo(onNext: _nextPage),
          Step3LocationRequest(onNext: _nextPage, onManual: () => _pageController.jumpToPage(3)),
          Step4ManualLocation(onNext: _nextPage),
          Step5UploadImage(onNext: _nextPage),
          const Step6Success(),
        ],
      ),
    );
  }
}