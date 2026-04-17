import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import 'guest_info_screen.dart';

const Map<String, IconData> _roomIconMap = {
  'fa-wifi': Icons.wifi, 'wifi': Icons.wifi,
  'fa-snowflake': Icons.ac_unit, 'ac': Icons.ac_unit,
  'fa-bath': Icons.bathtub,
  'fa-bread-slice': Icons.free_breakfast, 'breakfast': Icons.free_breakfast,
  'fa-hamburger': Icons.lunch_dining,
  'fa-utensils': Icons.restaurant,
  'fa-volume-mute': Icons.volume_off,
  'fa-swimming-pool': Icons.pool, 'pool': Icons.pool,
  'fa-dumbbell': Icons.fitness_center, 'gym': Icons.fitness_center,
  'fa-spa': Icons.spa, 'spa': Icons.spa,
  'tv': Icons.tv, 'parking': Icons.local_parking,
};

class _RoomSelection {
  final RoomTypeModel room;
  int quantity;
  _RoomSelection({required this.room, this.quantity = 0});
}

class RoomSelectionScreen extends StatefulWidget {
  final HotelModel hotel;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;

  const RoomSelectionScreen({
    super.key, required this.hotel,
    this.checkIn, this.checkOut, this.guests = 2,
  });

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  late List<_RoomSelection> _selections;

  @override
  void initState() {
    super.initState();
    _selections = widget.hotel.rooms.map((r) => _RoomSelection(room: r)).toList();
    if (_selections.isEmpty) _selections = _buildDemoRooms();
  }

  List<_RoomSelection> _buildDemoRooms() {
    return [
      _RoomSelection(room: RoomTypeModel(
        id: 'demo_1', hotelId: widget.hotel.id,
        name: 'Phòng giường đôi', price: 299211, capacity: 2,
        images: widget.hotel.images,
      )),
      _RoomSelection(room: RoomTypeModel(
        id: 'demo_2', hotelId: widget.hotel.id,
        name: 'Phòng 2 giường đơn', price: 299211, capacity: 2,
        images: widget.hotel.images,
      )),
    ];
  }

  int get _totalRooms => _selections.fold(0, (s, r) => s + r.quantity);
  double get _totalPrice => _selections.fold(0.0, (s, r) => s + r.room.price * r.quantity);

  int get _nights {
    if (widget.checkIn == null || widget.checkOut == null) return 1;
    return widget.checkOut!.difference(widget.checkIn!).inDays.clamp(1, 999);
  }

  String _fmt(double price) {
    final f = price.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = f.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(f[i]);
      c++;
    }
    return buf.toString().split('').reversed.join();
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
          if (_totalRooms > 0)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context)),
              const Expanded(child: Text('Chọn phòng',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              const Icon(Icons.favorite_border, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(_RoomSelection sel, int index) {
    final room = sel.room;
    final originalPrice = room.price * 1.15;
    final isSelected = sel.quantity > 0;

    final availableCount = room.rooms.isNotEmpty
        ? room.rooms.where((r) {
            final status = (r['status'] ?? r['Status'] ?? '').toString().toLowerCase();
            return status == 'available';
          }).length
        : 99; // Nếu không có data phòng vật lý → không giới hạn

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: AppColors.primaryLight, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên + ảnh
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(room.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight))),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: room.images.isNotEmpty
                      ? Image.network(room.images.first, width: 90, height: 70, fit: BoxFit.cover,
                          headers: const {'User-Agent': 'Mozilla/5.0'},
                          errorBuilder: (_, __, ___) => _imgPlaceholder())
                      : _imgPlaceholder(),
                ),
              ],
            ),
          ),

          // Thông tin phòng từ DB
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (room.bedType.isNotEmpty)
                  _feat(Icons.bed, '${room.bedNum} ${room.bedType}'),
                if (room.area > 0)
                  _feat(Icons.straighten, 'Diện tích: ${room.area.toStringAsFixed(0)}m²'),
                _feat(Icons.people_outline, 'Tối đa ${room.capacity} khách'),
                if (room.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(room.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                if (room.amenities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10, runSpacing: 4,
                    children: room.amenities.map((a) {
                      final icon = _roomIconMap[a.icon] ?? Icons.check_circle_outline;
                      return Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 13, color: AppColors.primaryLight),
                        const SizedBox(width: 3),
                        Text(a.name, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ]);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),

          // Chính sách + giá
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (room.policies.isNotEmpty)
                  ...room.policies.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(p.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  )),
                const SizedBox(height: 4),
                Row(children: const [
                  Icon(Icons.check, size: 15, color: Colors.green),
                  SizedBox(width: 6),
                  Text('Không cần thanh toán trước',
                      style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text('Giá cho 1 đêm, ${room.capacity} người lớn',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${_fmt(originalPrice)} VND',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Text('${_fmt(room.price)} VND',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCC0000))),
                  ],
                ),
                const Text('Đã bao gồm thuế và phí',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: availableCount == 0
                ? _buildSoldOutButton()
                : isSelected
                    ? _buildQuantityRow(sel, index, availableCount)
                    : _buildChooseButton(index),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              Icon(
                availableCount == 0 ? Icons.cancel_outlined : Icons.timelapse,
                size: 16,
                color: availableCount == 0 ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                availableCount == 0
                    ? 'Hết phòng trống'
                    : availableCount < 5
                        ? 'Chỉ còn $availableCount phòng — đặt ngay!'
                        : 'Còn $availableCount phòng trống',
                style: TextStyle(
                  fontSize: 13,
                  color: availableCount == 0 ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    width: 90, height: 70, color: const Color(0xFFE8EEF7),
    child: const Icon(Icons.hotel, color: AppColors.primaryLight, size: 28),
  );

  Widget _feat(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    ]),
  );

  Widget _buildChooseButton(int index) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () => setState(() => _selections[index].quantity = 1),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text('Chọn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildSoldOutButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: null, // disabled
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300], foregroundColor: Colors.grey[600],
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text('Hết phòng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildQuantityRow(_RoomSelection sel, int index, int maxQty) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => _showQuantityPicker(index, maxQty),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${sel.quantity} Phòng',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryLight, size: 20),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => setState(() => _selections[index].quantity = 0),
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
        ),
      ),
    ],
  );

  void _showQuantityPicker(int index, int maxQty) {
    // Giới hạn tối đa 5 hoặc số phòng available, lấy cái nhỏ hơn
    final limit = maxQty < 5 ? maxQty : 5;
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Chọn số lượng phòng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                Text(
                  'Còn $maxQty phòng',
                  style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(limit, (i) {
              final qty = i + 1;
              return ListTile(
                title: Text('$qty phòng'),
                trailing: _selections[index].quantity == qty
                    ? const Icon(Icons.check, color: AppColors.primaryLight) : null,
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

  Widget _buildBottomBar() {
    final totalForNights = _totalPrice * _nights;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity, color: const Color(0xFFFFF3CD),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Center(child: Text('Đặt phòng chỉ với 2 bước',
                style: TextStyle(fontSize: 13, color: Color(0xFF856404), fontWeight: FontWeight.w500))),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
            child: Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_fmt(totalForNights)} VND - $_totalRooms phòng',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const Text('Đã bao gồm thuế và phí',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                )),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final selected = _selections.where((s) => s.quantity > 0)
                        .map((s) => {'room': s.room, 'quantity': s.quantity}).toList();
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => GuestInfoScreen(
                        hotel: widget.hotel, selectedRooms: selected,
                        totalPrice: _totalPrice * _nights,
                        checkIn: widget.checkIn, checkOut: widget.checkOut,
                        guests: widget.guests, nights: _nights,
                      ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Đặt ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
