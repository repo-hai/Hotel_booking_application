import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/services/hotel_service.dart';
import 'room_selection_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  /// Truyền vào hotel đã có từ danh sách (hiển thị ngay),
  /// đồng thời fetch lại chi tiết đầy đủ từ API ở background.
  final HotelModel hotel;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int rooms;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
    this.checkIn,
    this.checkOut,
    this.guests = 2,
    this.rooms = 1,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late HotelModel _hotel;
  bool _isLoadingDetail = false;
  bool _isFavorite = false;
  bool _showFullDescription = false;
  bool _showAllAmenities = false;

  // Điểm đánh giá giả (vì backend chưa có reviews riêng)
  static const double _overallRating = 8.7;
  static const int _reviewCount = 93;
  static const Map<String, double> _ratingBreakdown = {
    'Sạch sẽ': 8.5,
    'Thoải mái': 9.0,
    'Tiện nghi': 6.9,
  };

  @override
  void initState() {
    super.initState();
    _hotel = widget.hotel;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (_hotel.rooms.isNotEmpty) return; // đã có rooms rồi
    setState(() => _isLoadingDetail = true);
    final detail = await HotelService.getHotelDetail(_hotel.id);
    if (mounted && detail != null) {
      setState(() {
        _hotel = detail;
        _isLoadingDetail = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingDetail = false);
    }
  }

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

  double get _lowestPrice {
    if (_hotel.rooms.isNotEmpty) {
      return _hotel.rooms.map((r) => r.price).reduce((a, b) => a < b ? a : b);
    }
    return _hotel.minRoomPrice ?? 0;
  }

  String get _ratingLabel {
    if (_overallRating >= 9) return 'Tuyệt vời';
    if (_overallRating >= 8) return 'Rất tốt';
    if (_overallRating >= 7) return 'Tốt';
    if (_overallRating >= 6) return 'Dễ chịu';
    return 'Trung bình';
  }

  static const Map<String, IconData> _amenityIconMap = {
    'wifi': Icons.wifi,
    'pool': Icons.pool,
    'parking': Icons.local_parking,
    'gym': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'spa': Icons.spa,
    'ac': Icons.ac_unit,
    'breakfast': Icons.free_breakfast,
    'elevator': Icons.elevator,
    'bar': Icons.local_bar,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    _buildDivider(),
                    _buildHighlightsSection(),
                    _buildDivider(),
                    _buildAmenitiesSection(),
                    _buildDivider(),
                    _buildRatingSection(),
                    _buildDivider(),
                    _buildDescriptionSection(),
                    _buildDivider(),
                    _buildPolicySection(),
                    _buildDivider(),
                    _buildContactSection(),
                    const SizedBox(height: 100), // space for bottom bar
                  ],
                ),
              ),
            ],
          ),
          // Bottom bar cố định
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

  // ── SLIVER APP BAR (ảnh + nút back/yêu thích) ──────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
                size: 20,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ),
        ),
      ],
      title: const Text(
        'Thông tin chỗ nghỉ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildGallery(),
      ),
    );
  }

  Widget _buildGallery() {
    final images = _hotel.images;
    if (images.isEmpty) {
      return Container(
        color: const Color(0xFFE8EEF7),
        child: const Center(
          child: Icon(Icons.hotel, size: 64, color: AppColors.primaryLight),
        ),
      );
    }

    // Lưới ảnh: 1 ảnh lớn bên trái + 2 ảnh nhỏ bên phải
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          children: [
            // Ảnh chính
            Expanded(
              flex: 2,
              child: _buildNetworkImage(images[0]),
            ),
            const SizedBox(width: 2),
            // 2 ảnh phụ
            if (images.length > 1)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildNetworkImage(
                          images.length > 1 ? images[1] : images[0]),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: _buildNetworkImage(
                          images.length > 2 ? images[2] : images[0]),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Badge số ảnh
        if (images.length > 3)
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${images.length - 3}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE8EEF7),
        child: const Icon(Icons.image_not_supported,
            color: AppColors.textHint, size: 32),
      ),
    );
  }

  // ── HEADER: tên, sao, địa chỉ, badge điểm ──────────────────────────────────

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _hotel.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge điểm đánh giá
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF003580),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Sao
          if (_hotel.star > 0)
            Row(
              children: List.generate(
                _hotel.star,
                (_) => const Icon(Icons.star, size: 16, color: AppColors.accent),
              ),
            ),
          const SizedBox(height: 6),
          // Địa chỉ
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.primaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_hotel.address}, ${_hotel.city}, Việt Nam',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Địa điểm rất tốt!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryLight,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ĐIỂM NỔI BẬT ───────────────────────────────────────────────────────────

  Widget _buildHighlightsSection() {
    final checkInStr = widget.checkIn != null
        ? 'T.${widget.checkIn!.weekday}, ${widget.checkIn!.day} Th${widget.checkIn!.month}'
        : 'T.2, 8 Th2';
    final checkOutStr = widget.checkOut != null
        ? 'T.${widget.checkOut!.weekday}, ${widget.checkOut!.day} Th${widget.checkOut!.month}'
        : 'T.3, 9 Th2';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm nổi bật của chỗ nghỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 2 tiện nghi nổi bật
          if (_hotel.amenities.isNotEmpty)
            Row(
              children: _hotel.amenities.take(2).map((a) {
                final icon = _amenityIconMap[a.icon] ?? Icons.check_circle_outline;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 22, color: AppColors.primaryLight),
                        const SizedBox(height: 4),
                        Text(
                          a.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          // Nhận/trả phòng
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.login,
                  label: 'Nhận phòng',
                  value: checkInStr,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.logout,
                  label: 'Trả phòng',
                  value: checkOutStr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Số phòng/khách
          _buildInfoTile(
            icon: Icons.people_outline,
            label: 'Số lượng phòng và khách',
            value: '${widget.rooms} phòng, ${widget.guests} người lớn, 0 trẻ em',
          ),
          const SizedBox(height: 12),
          // Giá
          if (_lowestPrice > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_formatPrice(_lowestPrice * 1.2)} VND',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatPrice(_lowestPrice)} VND',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC0000),
                  ),
                ),
              ],
            ),
            const Text(
              'Đã bao gồm thuế và phí',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TIỆN NGHI ───────────────────────────────────────────────────────────────

  Widget _buildAmenitiesSection() {
    final amenities = _hotel.amenities;
    if (amenities.isEmpty) return const SizedBox();

    final shown = _showAllAmenities ? amenities : amenities.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện nghi chỗ nghỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...shown.map((a) {
            final icon = _amenityIconMap[a.icon] ?? Icons.check_circle_outline;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    a.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (amenities.length > 4) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _showAllAmenities = !_showAllAmenities),
              child: Text(
                _showAllAmenities
                    ? 'Thu gọn'
                    : 'Xem tất cả ${amenities.length} tiện nghi',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ĐÁNH GIÁ ───────────────────────────────────────────────────────────────

  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá của khách',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Badge tổng điểm
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF003580),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ratingLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Từ $_reviewCount đánh giá',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Thanh progress từng tiêu chí
          ..._ratingBreakdown.entries.map((e) => _buildRatingBar(e.key, e.value)),
          const SizedBox(height: 8),
          // Ghi chú điểm thấp
          Row(
            children: [
              const Icon(Icons.arrow_downward, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Điểm thấp p tại ${_hotel.city}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Xem tất cả $_reviewCount đánh giá',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double value) {
    final color = value >= 8.0
        ? Colors.green
        : value >= 6.0
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── MÔ TẢ ──────────────────────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    final description =
        'Chỗ nghỉ cung cấp chỗ nghỉ tại ${_hotel.city}. '
        'Khách sạn ${_hotel.star} sao nổi bật với dịch vụ phòng và quầy lễ tân 24 giờ. '
        'Tại đây có tầm nhìn phong cảnh và khách hàng có thể sử dụng WiFi miễn phí. '
        'Chỗ nghỉ cách trung tâm thành phố khoảng 2km, thuận tiện cho việc di chuyển và khám phá.';

    const shortLength = 120;
    final isLong = description.length > shortLength;
    final displayText = (!_showFullDescription && isLong)
        ? '${description.substring(0, shortLength)}...'
        : description;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () =>
                  setState(() => _showFullDescription = !_showFullDescription),
              child: Text(
                _showFullDescription ? 'Thu gọn' : 'Đọc thêm',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── CHÍNH SÁCH ─────────────────────────────────────────────────────────────

  Widget _buildPolicySection() {
    final checkInTime = widget.checkIn != null ? '12:00 đến 13:00' : '12:00 đến 13:00';
    final checkOutTime = '10:00 đến 11:30';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chính sách',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildPolicyRow(Icons.login, 'Nhận phòng từ $checkInTime'),
          _buildPolicyRow(Icons.logout, 'Trả phòng từ $checkOutTime'),
          _buildPolicyRow(Icons.free_breakfast_outlined,
              'Bữa sáng theo yêu cầu (tính phí trước)'),
          _buildPolicyRow(
              Icons.credit_card_off, 'Không đặt phòng hoặc phí thẻ tín dụng'),
          _buildPolicyRow(Icons.family_restroom, 'Miễn phí cho trẻ em theo quy định'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Xem toàn bộ chính sách',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIÊN HỆ ────────────────────────────────────────────────────────────────

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liên hệ với chỗ nghỉ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primaryLight, size: 18),
              label: const Text(
                'Nhắn tin với chỗ nghỉ',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primaryLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_lowestPrice > 0) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'từ',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  '${_formatPrice(_lowestPrice)} VND',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const Text(
                  '/đêm',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomSelectionScreen(
                      hotel: _hotel,
                      checkIn: widget.checkIn,
                      checkOut: widget.checkOut,
                      guests: widget.guests,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Chọn phòng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 8, color: const Color(0xFFF5F5F5));
  }
}
