import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import 'price_calendar_screen.dart';
import 'edit_room_step3_screen.dart';

class EditRoomStep2Screen extends StatefulWidget {
  final String? roomTypeId;
  const EditRoomStep2Screen({super.key, this.roomTypeId});

  @override
  State<EditRoomStep2Screen> createState() => _EditRoomStep2ScreenState();
}

class _EditRoomStep2ScreenState extends State<EditRoomStep2Screen> {
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  int _currentPrice = 800000;
  String _selectedPolicy = "Không thể hoàn trả";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

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
      _currentPrice = rt.price;
      _priceController.text = "${NumberFormat("#,###").format(_currentPrice)}VND";
      _descriptionController.text = rt.description;
      _selectedPolicy = rt.cancellationPolicy;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PriceCalendarScreen(initialPrice: _currentPrice)),
    );

    if (result != null && result is int) {
      setState(() {
        _currentPrice = result;
        _priceController.text = "${NumberFormat("#,###").format(_currentPrice)}VND";
      });
      _syncToProvider();
    }
  }

  void _syncToProvider() {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final rId = widget.roomTypeId ?? (provider.roomTypes.isNotEmpty ? provider.roomTypes[0].id : "");
    if (rId.isNotEmpty) {
      final currentRt = provider.roomTypes.firstWhere((r) => r.id == rId);
      final updatedRt = currentRt.copyWith(
        price: _currentPrice,
        description: _descriptionController.text,
        cancellationPolicy: _selectedPolicy,
      );
      provider.updateRoomType(updatedRt);
    }
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              const TextSpan(
                children: [
                   TextSpan(text: "Giá phòng", style: TextStyle(fontWeight: FontWeight.bold)),
                   TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black),
                  onPressed: _openCalendar,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildField("Mô tả phòng *", _descriptionController, "Nhập mô tả"),
            
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: "Chính sách hoàn trả", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDropdown(),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _syncToProvider(); // Lưu lần cuối trước khi sang step sau
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditRoomStep3Screen(roomTypeId: widget.roomTypeId)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5AAC),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Tiếp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
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
      TextFormField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildDropdown() {
    final List<String> options = [
      "Không thể hoàn trả",
      "Hoàn 50% trước 24h",
      "Hoàn 100% trước 24h",
      "Hoàn 100% trước 48h",
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedPolicy,
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _selectedPolicy = v;
              });
            }
          },
        ),
      ),
    );
  }
}