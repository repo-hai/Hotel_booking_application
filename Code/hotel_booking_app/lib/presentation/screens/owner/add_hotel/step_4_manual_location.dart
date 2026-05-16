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
  // Danh sách tỉnh/thành phố có trong DB
  static const List<String> _locations = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
    'Kiên Giang (Phú Quốc)',
    'Lào Cai (Sapa)',
    'Lâm Đồng (Đà Lạt)',
    'Khánh Hòa (Nha Trang)',
    'Bà Rịa - Vũng Tàu',
    'Quảng Ninh (Hạ Long)',
    'Thừa Thiên Huế',
    'Cần Thơ',
    'Quảng Nam (Hội An)',
    'Bình Định (Quy Nhơn)',
    'Thanh Hóa',
    'Phú Thọ',
    'Lạng Sơn',
    'Hòa Bình',
    'Bắc Ninh',
    'Nam Định',
    'Ninh Bình',
    'Sơn La (Mộc Châu)',
    'Vĩnh Phúc',
    'Ninh Thuận',
    'Quảng Trị',
    'Tiền Giang',
  ];

  String? _selectedLocation;

  void _onNext() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tỉnh/thành phố'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    if (provider.draftHotel != null) {
      provider.draftHotel = Hotel(
        id: provider.draftHotel!.id,
        type: provider.draftHotel!.type,
        name: provider.draftHotel!.name,
        description: provider.draftHotel!.description,
        telephone: provider.draftHotel!.telephone,
        location: _selectedLocation!,
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vị trí khách sạn",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Chọn tỉnh/thành phố nơi khách sạn tọa lạc",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tỉnh/Thành phố',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Chọn tỉnh/thành phố',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      borderRadius: BorderRadius.circular(10),
                      items: _locations
                          .map((loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedLocation = val),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5AAC),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _onNext,
            child: const Text(
              "Tiếp",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
