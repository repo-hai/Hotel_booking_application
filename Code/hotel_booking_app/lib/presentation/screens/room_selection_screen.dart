import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import 'guest_info_screen.dart';

/// Map icon tiện nghi phòng
const Map<String, IconData> _roomIconMap = {
  'wifi': Icons.wifi,
  'ac': Icons.ac_unit,
  'tv': Icons.tv,
  'pool': Icons.pool,
  'parking': Icons.local_parking,
  'breakfast': Icons.free_breakfast,
  'gym': Icons.fitness_center,
  'spa': Icons.spa,
};

/// Trạng thái chọn của 1 loại phòng
class _RoomSelection {
  final RoomTypeModel room;
  int quantity; // 0 = chưa chọn

  _RoomSelection({required this.room, this.quantity = 0});
}

class RoomSelectionScreen extends StatefulWidget {
  final HotelModel hotel;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  const RoomSelectionScreen({
    super.key,
    required this.hotel,
    this.checkIn,
    this.checkOut,
    this.guests = 2,
  });

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  late List<_RoomSelection> _selections;

  @override
  void initState() {
    super.initState();
    _selections = widget.hotel.rooms
        .map((r) => _RoomSelection(room: r))
        .toList();

    // Nếu không có rooms từ API, tạo dữ liệu mẫu để demo
    if (_selections.isEmpty) {
      _selections = _buildDemoRooms();
    }
  }

  List<_RoomSelection> _buildDemoRooms() {
    final hotelId = widget.hotel.id;
    return [
      _RoomSelection(
        room: RoomTypeModel(
          id: 'demo_1',
          hotelId: hotelId,
          name: 'Phòng giường đôi',
          price: 299211,
          capacity: 2,
          images: widget.hotel.images,
        ),
      ),
      _RoomSelection(
        room: RoomTypeModel(
          id: 'demo_2',
          hotelId: hotelId,
          name: 'Phòng 2 giường đơn',
          price: 299211,
          capacity: 2,
          images: widget.hotel.images,
        ),
      ),
    ];
  }

  // Tổng số phòng đã chọn
  int get _totalRooms =>
      _selections.fold(0, (sum, s) => sum + s.quantity);

  // Tổng tiền
  double get _totalPrice => _selections.fold(
      0.0, (sum, s) => sum + s.room.price * s.quantity);

  String _formatPrice(double price) {
    final formatted = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(formatted[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  int get _nights {
    if (widget.checkIn == null || widget.checkOut == null) return 1;
    return widget.checkOut!.difference(widget.checkIn!).inDays.clamp(1, 999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                  itemCount: _selections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildRoomCard(_selections[i], i),
                ),
              ),
            ],
          ),
          // Bottom bar xuất hiện khi đã chọn ít nhất 1 phòng
          if (_totalRooms > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Chọn phòng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.favorite_border, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // ── ROOM CARD ──────────────────────────────────────────────────────────────

  Widget _buildRoomCard(_RoomSelection sel, int index) {
    final room = sel.room;
    final originalPrice = room.price * 1.2;
    final isSelected = sel.quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: AppColors.primaryLight, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: tên + ảnh
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên phòng
                Expanded(
                  child: Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Ảnh phòng
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: room.images.isNotEmpty
                      ? Image.network(
                          room.images.first,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildImgPlaceholder(),
                        )
                      : _buildImgPlaceholder(),
                ),
              ],
            ),
          ),

          // Thông tin phòng
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoomFeature(Icons.bed, _getBedLabel(room)),
                _buildRoomFeature(Icons.straighten, 'Diện tích: 10m2'),
                _buildRoomFeatureRow([
                  _FeatureItem(Icons.wifi, 'WiFi Miễn phí'),
                  _FeatureItem(Icons.tv, 'TV màn hình phẳng'),
                ]),
                _buildRoomFeature(Icons.ac_unit, 'Điều hòa không khí'),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // Giá & điều kiện
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Giá cho ${room.capacity} người lớn',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.check, size: 15, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'Không cần thanh toán trước',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Giá cho 1 đêm, 2 người lớn',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${_formatPrice(originalPrice)} VND',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatPrice(room.price)} VND',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCC0000),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Đã bao gồm thuế và phí',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nút chọn / bộ đếm số lượng
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: isSelected
                ? _buildQuantityRow(sel, index)
                : _buildChooseButton(index),
          ),

          const SizedBox(height: 10),

          // Badge còn phòng
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                const Icon(Icons.timelapse, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  'Chúng tôi còn ${4 + index} phòng',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImgPlaceholder() {
    return Container(
      width: 80,
      height: 60,
      color: const Color(0xFFE8EEF7),
      child: const Icon(Icons.hotel, color: AppColors.primaryLight, size: 28),
    );
  }

  Widget _buildRoomFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomFeatureRow(List<_FeatureItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getBedLabel(RoomTypeModel room) {
    if (room.name.toLowerCase().contains('đôi') ||
        room.name.toLowerCase().contains('double')) {
      return '1 giường đôi lớn';
    }
    if (room.name.toLowerCase().contains('đơn') ||
        room.name.toLowerCase().contains('single') ||
        room.name.toLowerCase().contains('twin')) {
      return '2 giường đơn';
    }
    return '${room.capacity} giường';
  }

  // Nút "Chọn" khi chưa chọn
  Widget _buildChooseButton(int index) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selections[index].quantity = 1);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Chọn',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Dropdown số lượng + nút xóa khi đã chọn
  Widget _buildQuantityRow(_RoomSelection sel, int index) {
    return Row(
      children: [
        // Dropdown số lượng phòng
        Expanded(
          child: GestureDetector(
            onTap: () => _showQuantityPicker(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${sel.quantity} Phòng',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primaryLight, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Nút xóa
        GestureDetector(
          onTap: () => setState(() => _selections[index].quantity = 0),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.delete_outline,
                color: Colors.red.shade400, size: 20),
          ),
        ),
      ],
    );
  }

  void _showQuantityPicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn số lượng phòng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(5, (i) {
              final qty = i + 1;
              return ListTile(
                title: Text('$qty phòng'),
                trailing: _selections[index].quantity == qty
                    ? const Icon(Icons.check, color: AppColors.primaryLight)
                    : null,
                onTap: () {
                  setState(() => _selections[index].quantity = qty);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM BAR (xuất hiện khi đã chọn phòng) ──────────────────────────────

  Widget _buildBottomBar() {
    final totalForNights = _totalPrice * _nights;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner vàng "Đặt phòng chỉ với 2 bước"
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF3CD),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Center(
              child: Text(
                'Đặt phòng chỉ với 2 bước',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF856404),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Tổng tiền + nút đặt ngay
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatPrice(totalForNights)} VND - $_totalRooms phòng',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Đã bao gồm thuế và phí',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final selected = _selections
                        .where((s) => s.quantity > 0)
                        .map((s) => {
                              'room': s.room,
                              'quantity': s.quantity,
                            })
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GuestInfoScreen(
                          hotel: widget.hotel,
                          selectedRooms: selected,
                          totalPrice: _totalPrice * _nights,
                          checkIn: widget.checkIn,
                          checkOut: widget.checkOut,
                          guests: widget.guests,
                          nights: _nights,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đặt ngay',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation() {
    final selectedRooms = _selections.where((s) => s.quantity > 0).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận đặt phòng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.hotel.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...selectedRooms.map((s) => Text(
                  '• ${s.room.name} x${s.quantity}: ${_formatPrice(s.room.price * s.quantity)} VND',
                  style: const TextStyle(fontSize: 13),
                )),
            const SizedBox(height: 8),
            Text(
              'Tổng: ${_formatPrice(_totalPrice * _nights)} VND ($_nights đêm)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Gọi API tạo booking
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

// ── Helper classes ────────────────────────────────────────────────────────────

class _FeatureItem {
  final IconData icon;
  final String label;
  const _FeatureItem(this.icon, this.label);
}
