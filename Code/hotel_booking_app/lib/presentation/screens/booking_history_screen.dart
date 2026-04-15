import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking_history_model.dart';
import '../../data/services/booking_service.dart';
import 'booking_receipt_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  /// initialTab: 0=Đang hoạt động, 1=Đã qua, 2=Đã hủy
  final int initialTab;
  const BookingHistoryScreen({super.key, this.initialTab = 0});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<BookingHistoryModel> _active = [];
  List<BookingHistoryModel> _past = [];
  List<BookingHistoryModel> _cancelled = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTab);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final all = await BookingService.getBookings();
    if (mounted) {
      setState(() {
        _active = all.where((b) => b.isActive).toList();
        _past = all.where((b) => b.isPast).toList();
        _cancelled = all.where((b) => b.isCancelled).toList();
        _isLoading = false;
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

  String _formatDateShort(String? iso) {
    if (iso == null) return '---';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day} Th${dt.month}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryLight, strokeWidth: 2))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_active, 'active'),
                      _buildList(_past, 'past'),
                      _buildList(_cancelled, 'cancelled'),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              if (Navigator.canPop(context))
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              const Text(
                'Lịch sử đặt phòng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTab('Đang hoạt động', 0),
          _buildTab('Đã qua', 1),
          _buildTab('Đã hủy', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _tabController.index == index;
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          final isSelected = _tabController.index == index;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(color: AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<BookingHistoryModel> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.luggage_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              type == 'active'
                  ? 'Chưa có đặt phòng nào đang hoạt động'
                  : type == 'past'
                      ? 'Chưa có đặt phòng nào đã qua'
                      : 'Chưa có đặt phòng nào bị hủy',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryLight,
      onRefresh: _loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildBookingCard(items[i], type),
      ),
    );
  }

  Widget _buildBookingCard(BookingHistoryModel booking, String type) {
    final isPending = booking.status == 'Cancel_Requested';
    final isConfirmed = booking.status == 'Confirmed';
    final isCancelled = booking.status == 'Cancelled';
    final isPast = booking.status == 'Completed';

    Color statusColor = Colors.green;
    if (isPending) statusColor = Colors.orange;
    if (isCancelled) statusColor = Colors.red;
    if (isPast) statusColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingReceiptScreen(booking: booking),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: isPending
              ? Border.all(color: Colors.orange.shade200)
              : isConfirmed
                  ? Border.all(color: Colors.green.shade200)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge trạng thái (chỉ hiện khi active)
            if (type == 'active')
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                ),
                child: Text(
                  booking.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Thông tin khách sạn
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: booking.hotelImages.isNotEmpty
                        ? Image.network(
                            booking.hotelImages.first,
                            width: 80,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImgPlaceholder(),
                          )
                        : _buildImgPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  // Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.hotelName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${booking.hotelAddress}, ${booking.hotelCity}, Việt Nam',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_formatDateShort(booking.checkIn)} - ${_formatDateShort(booking.checkOut)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_formatPrice(booking.total)} VND',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Badge trạng thái inline
                        Text(
                          isCancelled
                              ? 'Đã hủy'
                              : isPast
                                  ? 'Đã hoàn thành'
                                  : '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCancelled ? Colors.red : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  _buildAction(
                    icon: Icons.chat_bubble_outline,
                    label: 'Liên hệ với chỗ nghỉ',
                    onTap: () {},
                  ),
                  if (type == 'active')
                    _buildAction(
                      icon: Icons.cancel_outlined,
                      label: 'Hủy đặt phòng',
                      onTap: () => _confirmCancel(booking),
                      color: Colors.red,
                    ),
                  if (type != 'active')
                    _buildAction(
                      icon: Icons.refresh,
                      label: 'Đặt lại phòng',
                      onTap: () {},
                    ),
                  if (type == 'past')
                    _buildAction(
                      icon: Icons.star_border,
                      label: 'Đánh giá chỗ nghỉ',
                      onTap: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgPlaceholder() {
    return Container(
      width: 80,
      height: 70,
      color: const Color(0xFFE8EEF7),
      child: const Icon(Icons.hotel, color: AppColors.primaryLight, size: 28),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: color ?? AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BookingHistoryModel booking) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelReasonSheet(hotelName: booking.hotelName),
    );

    if (reason == null || !mounted) return;

    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      ),
    );

    final ok = await BookingService.cancelBooking(booking.id, reason);

    if (!mounted) return;
    Navigator.pop(context); // đóng loading

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Đã gửi yêu cầu hủy thành công!'
          : 'Không thể hủy. Vui lòng thử lại!'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));

    if (ok) {
      // Reload và chuyển sang tab "Đã hủy"
      await _loadAll();
      if (mounted) {
        _tabController.animateTo(2);
      }
    }
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2, // Tab "Đặt chỗ"
      onTap: (index) {
        if (index == 0) Navigator.popUntil(context, (r) => r.isFirst);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.search), label: 'Tìm kiếm'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), label: 'Đã lưu'),
        BottomNavigationBarItem(
            icon: Icon(Icons.luggage_outlined), label: 'Đặt chỗ'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Tài khoản'),
      ],
    );
  }
}

// ── Bottom sheet chọn lý do hủy ─────────────────────────────────────────────

class _CancelReasonSheet extends StatefulWidget {
  final String hotelName;
  const _CancelReasonSheet({required this.hotelName});

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  static const List<String> _reasons = [
    'Lịch trình thay đổi',
    'Tôi muốn thay đổi thông tin đặt phòng',
    'Chỗ nghỉ không phản hồi tin nhắn',
    'Không còn nhu cầu',
    'Khác',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tiêu đề
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Lý do hủy',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Banner xanh lá "Hủy phòng miễn phí"
          Container(
            width: double.infinity,
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Text(
              'Hủy phòng miễn phí  (theo chính sách chỗ nghỉ)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Danh sách lý do
          ..._reasons.map((reason) => _buildReasonTile(reason)),

          // Nút xác nhận
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Xác nhận hủy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    final isSelected = _selected == reason;
    return InkWell(
      onTap: () => setState(() => _selected = reason),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.border,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
