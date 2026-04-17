import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/review_model.dart';
import '../../data/services/hotel_service.dart';
import 'room_selection_screen.dart';

// Map icon Firebase (fa-*) sang Material Icons
const Map<String, IconData> _iconMap = {
  'fa-wifi': Icons.wifi,
  'wifi': Icons.wifi,
  'fa-swimming-pool': Icons.pool,
  'pool': Icons.pool,
  'fa-spa': Icons.spa,
  'spa': Icons.spa,
  'fa-dumbbell': Icons.fitness_center,
  'gym': Icons.fitness_center,
  'fa-glass-martini-alt': Icons.local_bar,
  'bar': Icons.local_bar,
  'fa-utensils': Icons.restaurant,
  'restaurant': Icons.restaurant,
  'fa-snowflake': Icons.ac_unit,
  'ac': Icons.ac_unit,
  'fa-bath': Icons.bathtub,
  'fa-bread-slice': Icons.free_breakfast,
  'breakfast': Icons.free_breakfast,
  'fa-hamburger': Icons.lunch_dining,
  'fa-volume-mute': Icons.volume_off,
  'fa-parking': Icons.local_parking,
  'parking': Icons.local_parking,
  'elevator': Icons.elevator,
};

class HotelDetailScreen extends StatefulWidget {
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
  bool _isFavorite = false;
  bool _showFullDescription = false;
  bool _showAllAmenities = false;
  bool _showAllReviews = false;

  // Reviews thực từ API
  HotelReviewSummary _reviewSummary = HotelReviewSummary.empty();
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _hotel = widget.hotel;
    _fetchDetail();
    _fetchReviews();
  }

  Future<void> _fetchDetail() async {
    if (_hotel.rooms.isNotEmpty) return;
    final detail = await HotelService.getHotelDetail(_hotel.id);
    if (mounted && detail != null) {
      setState(() => _hotel = detail);
    }
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    final summary = await HotelService.getHotelReviews(_hotel.id, limit: 20);
    if (mounted) {
      setState(() {
        _reviewSummary = summary;
        _isLoadingReviews = false;
      });
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

  String get _ratingLabel => _reviewSummary.ratingLabel;

  IconData _getIcon(String icon) => _iconMap[icon] ?? Icons.check_circle_outline;

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
                    _buildContactSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR ──────────────────────────────────────────────────────────

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
      title: const Text('Thông tin chỗ nghỉ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(background: _buildGallery()),
    );
  }

  Widget _buildGallery() {
    final images = _hotel.images;
    if (images.isEmpty) {
      return Container(
        color: const Color(0xFFE8EEF7),
        child: const Center(child: Icon(Icons.hotel, size: 64, color: AppColors.primaryLight)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _img(images[0])),
            const SizedBox(width: 2),
            if (images.length > 1)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _img(images.length > 1 ? images[1] : images[0])),
                    const SizedBox(height: 2),
                    Expanded(child: _img(images.length > 2 ? images[2] : images[0])),
                  ],
                ),
              ),
          ],
        ),
        if (images.length > 3)
          Positioned(
            right: 12, bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text('+${images.length - 3}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _img(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'},
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: const Color(0xFFE8EEF7),
            child: const Center(child: CircularProgressIndicator(color: AppColors.primaryLight, strokeWidth: 2)));
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE8EEF7),
        child: const Icon(Icons.image_not_supported, color: AppColors.textHint, size: 32),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_hotel.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    if (_hotel.type.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_hotel.type,
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF003580), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  _reviewSummary.totalReviews > 0
                      ? _reviewSummary.ratingOutOf10.toStringAsFixed(1)
                      : '—',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_hotel.star > 0)
            Row(children: List.generate(_hotel.star,
                (_) => const Icon(Icons.star, size: 16, color: AppColors.accent))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.primaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text('${_hotel.address}, Việt Nam',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
        : 'Chưa chọn';
    final checkOutStr = widget.checkOut != null
        ? 'T.${widget.checkOut!.weekday}, ${widget.checkOut!.day} Th${widget.checkOut!.month}'
        : 'Chưa chọn';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Điểm nổi bật của chỗ nghỉ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          // 2 tiện nghi nổi bật dạng card
          if (_hotel.amenities.isNotEmpty)
            Row(
              children: _hotel.amenities.take(2).map((a) {
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
                        Icon(_getIcon(a.icon), size: 22, color: AppColors.primaryLight),
                        const SizedBox(height: 4),
                        Text(a.name,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            textAlign: TextAlign.center, maxLines: 2),
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
              Expanded(child: _infoTile(Icons.login, 'Nhận phòng', checkInStr)),
              const SizedBox(width: 8),
              Expanded(child: _infoTile(Icons.logout, 'Trả phòng', checkOutStr)),
            ],
          ),
          const SizedBox(height: 8),
          _infoTile(Icons.people_outline, 'Số lượng phòng và khách',
              '${widget.rooms} phòng, ${widget.guests} người lớn'),
          const SizedBox(height: 12),
          // Giá
          if (_lowestPrice > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${_formatPrice(_lowestPrice * 1.15)} VND',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
                Text('${_formatPrice(_lowestPrice)} VND',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFCC0000))),
              ],
            ),
            const Text('Đã bao gồm thuế và phí',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
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
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TIỆN NGHI KHÁCH SẠN ─────────────────────────────────────────────────────

  Widget _buildAmenitiesSection() {
    final amenities = _hotel.amenities;
    if (amenities.isEmpty) return const SizedBox();
    final shown = _showAllAmenities ? amenities : amenities.take(4).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiện nghi chỗ nghỉ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...shown.map((a) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(_getIcon(a.icon), size: 18, color: Colors.green),
                const SizedBox(width: 10),
                Text(a.name, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          )),
          if (amenities.length > 4) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _showAllAmenities = !_showAllAmenities),
              child: Text(
                _showAllAmenities ? 'Thu gọn' : 'Xem tất cả ${amenities.length} tiện nghi',
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ĐÁNH GIÁ (từ Reviews thực) ─────────────────────────────────────────────

  Widget _buildRatingSection() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryLight, strokeWidth: 2)),
      );
    }

    if (_reviewSummary.totalReviews == 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Đánh giá của khách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 12),
            Text('Chưa có đánh giá nào cho khách sạn này.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final rating10 = _reviewSummary.ratingOutOf10;
    final toShow = _showAllReviews
        ? _reviewSummary.reviews
        : _reviewSummary.reviews.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đánh giá của khách',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Badge tổng điểm
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF003580), borderRadius: BorderRadius.circular(6)),
                child: Text(rating10.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ratingLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Từ ${_reviewSummary.totalReviews} đánh giá',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Phân bổ sao (1-5)
          ...[5, 4, 3, 2, 1].map((star) {
            final count = _reviewSummary.breakdown[star] ?? 0;
            final pct = _reviewSummary.totalReviews > 0
                ? count / _reviewSummary.totalReviews
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Row(
                      children: [
                        Text('$star', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Icon(Icons.star, size: 12, color: AppColors.accent),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          star >= 4 ? Colors.green : star == 3 ? Colors.orange : Colors.red,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text('$count',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Danh sách bình luận
          ...toShow.map((r) => _buildReviewItem(r)),

          if (_reviewSummary.reviews.length > 3) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _showAllReviews = !_showAllReviews),
              child: Text(
                _showAllReviews
                    ? 'Thu gọn'
                    : 'Xem tất cả ${_reviewSummary.totalReviews} đánh giá',
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    // Rating 1-5 → hiển thị sao
    final stars = review.rating.round().clamp(1, 5);
    final dateStr = review.createdAt != null
        ? () {
            try {
              final dt = DateTime.parse(review.createdAt!);
              return '${dt.day}/${dt.month}/${dt.year}';
            } catch (_) {
              return '';
            }
          }()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                child: Text(
                  review.guestName.isNotEmpty ? review.guestName[0].toUpperCase() : 'K',
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.guestName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (dateStr.isNotEmpty)
                      Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              // Sao đánh giá
              Row(
                children: List.generate(5, (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  size: 14,
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  // ── MÔ TẢ (từ DB) ──────────────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    // Dùng description thực từ DB
    final description = _hotel.description.isNotEmpty
        ? _hotel.description
        : 'Chưa có mô tả cho chỗ nghỉ này.';

    const shortLength = 150;
    final isLong = description.length > shortLength;
    final displayText = (!_showFullDescription && isLong)
        ? '${description.substring(0, shortLength)}...'
        : description;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(displayText,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          if (isLong) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _showFullDescription = !_showFullDescription),
              child: Text(
                _showFullDescription ? 'Thu gọn' : 'Đọc thêm',
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── LIÊN HỆ (telephone + email từ DB) ──────────────────────────────────────

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Liên hệ với chỗ nghỉ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          // Số điện thoại từ DB
          if (_hotel.telephone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  Text(_hotel.telephone,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                ],
              ),
            ),
          // Email từ DB
          if (_hotel.email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_hotel.email,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          // Nút nhắn tin
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryLight, size: 18),
              label: const Text('Nhắn tin với chỗ nghỉ',
                  style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primaryLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_lowestPrice > 0) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('từ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('${_formatPrice(_lowestPrice)} VND',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                const Text('/đêm', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RoomSelectionScreen(
                    hotel: _hotel,
                    checkIn: widget.checkIn,
                    checkOut: widget.checkOut,
                    guests: widget.guests,
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Chọn phòng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 8, color: const Color(0xFFF5F5F5));
}
