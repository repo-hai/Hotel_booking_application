import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/booking_customer_info.dart';
import '../../data/models/voucher_model.dart';
import '../../data/services/hotel_service.dart';
import 'booking_history_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final HotelModel hotel;
  final BookingCustomerInfo customerInfo;
  final List<Map<String, dynamic>> selectedRooms;
  final double totalPrice;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final int nights;

  const BookingDetailScreen({
    super.key,
    required this.hotel,
    required this.customerInfo,
    required this.selectedRooms,
    required this.totalPrice,
    this.checkIn,
    this.checkOut,
    this.guests = 2,
    this.nights = 1,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isBooking = false;

  // Voucher
  VoucherModel? _selectedVoucher;
  List<VoucherModel> _vouchers = [];
  bool _isLoadingVouchers = false;

  // Giá sau khi áp voucher
  double get _discount => _selectedVoucher?.discountAmount ?? 0;
  double get _originalPrice => widget.totalPrice;
  double get _finalPrice => (widget.totalPrice - _discount).clamp(0, double.infinity);

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoadingVouchers = true);
    final list = await HotelService.getAvailableVouchers(orderTotal: widget.totalPrice);
    if (mounted) setState(() { _vouchers = list; _isLoadingVouchers = false; });
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '---';
    const weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final wd = weekdays[dt.weekday - 1];
    return '$wd, ${dt.day} Tháng ${dt.month}, ${dt.year}';
  }

  String get _roomSummary {
    return widget.selectedRooms.map((s) {
      final room = s['room'] as RoomTypeModel;
      final qty = s['quantity'] as int;
      return '${qty} x ${room.name}';
    }).join(', ');
  }

  int get _totalRooms =>
      widget.selectedRooms.fold(0, (sum, s) => sum + (s['quantity'] as int));

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    try {
      final bookedRooms = widget.selectedRooms.map((s) {
        final room = s['room'] as RoomTypeModel;
        final qty = s['quantity'] as int;
        return {
          'roomTypeId': room.id,
          'quantity': qty,
          'price': room.price,
        };
      }).toList();

      final body = {
        'hotelId': widget.hotel.id,
        'hotelName': widget.hotel.name,
        'customerInfo': widget.customerInfo.toJson(),
        'checkIn': widget.checkIn?.toIso8601String(),
        'checkOut': widget.checkOut?.toIso8601String(),
        'bookedRooms': bookedRooms,
        'originalPrice': _originalPrice,
        'discount': _discount,
        'totalPrice': _finalPrice,
        if (_selectedVoucher != null) 'voucherCode': _selectedVoucher!.code,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final bookingId = data['bookingId'] ?? 'N/A';
        _showSuccessDialog(bookingId);
      } else {
        _showErrorSnackbar('Đặt phòng thất bại. Vui lòng thử lại!');
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Lỗi kết nối. Vui lòng thử lại!');
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showSuccessDialog(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Đặt phòng thành công!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đặt phòng: $bookingId',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.hotel.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Chuyển sang lịch sử đặt phòng, tab "Đang hoạt động"
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const BookingHistoryScreen(initialTab: 0),
                  ),
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xem đặt phòng của tôi'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildHotelCard(),
                  const SizedBox(height: 12),
                  _buildVoucherSection(),
                  const SizedBox(height: 12),
                  _buildBookingSummaryCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Thông tin chỗ nghỉ',
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

  // Card thông tin khách sạn
  Widget _buildHotelCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
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
          // Tên + badge điểm
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.hotel.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge điểm — chỉ hiển thị nếu có rating thực
              if (widget.hotel.rating != null && widget.hotel.rating! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (widget.hotel.rating! * 2).toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Sao
          if (widget.hotel.star > 0)
            Row(
              children: List.generate(
                widget.hotel.star,
                (_) => const Icon(Icons.star, size: 14, color: AppColors.accent),
              ),
            ),
          const SizedBox(height: 6),
          // Địa chỉ
          Text(
            widget.hotel.address.isNotEmpty
                ? '${widget.hotel.address}, Việt Nam'
                : '${widget.hotel.city}, Việt Nam',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          // Nhận / Trả phòng
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhận phòng',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.checkIn),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trả phòng',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.checkOut),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card tóm tắt đặt phòng + bảng giá
  Widget _buildBookingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
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
          // Bạn đã chọn
          const Text(
            'Bạn đã chọn',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.nights} đêm, $_totalRooms phòng, ${widget.guests} người lớn',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chi tiết:  $_roomSummary',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Bảng giá
          _buildPriceRow('Giá gốc:', _originalPrice),
          if (_discount > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Giảm giá:', -_discount, isDiscount: true),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Tổng
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Giá:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (_discount > 0) ...[
                        Text(
                          '${_formatPrice(_originalPrice)} VND',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${_formatPrice(_finalPrice)} VND',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isDiscount = false}) {
    final color = isDiscount ? Colors.green : AppColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '${isDiscount ? "- " : ""}${_formatPrice(amount.abs())} VND',
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: isDiscount ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mã giảm giá',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _isLoadingVouchers ? null : _showVoucherPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedVoucher != null ? AppColors.primaryLight : AppColors.border,
                  width: _selectedVoucher != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _selectedVoucher != null
                    ? AppColors.primaryLight.withValues(alpha: 0.05)
                    : AppColors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 18,
                    color: _selectedVoucher != null ? AppColors.primaryLight : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _isLoadingVouchers
                        ? const Text('Đang tải voucher...', style: TextStyle(fontSize: 14, color: AppColors.textHint))
                        : _selectedVoucher != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedVoucher!.code,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                                  Text(_selectedVoucher!.discountLabel,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              )
                            : Text(
                                _vouchers.isEmpty ? 'Không có voucher khả dụng' : 'Chọn mã giảm giá (${_vouchers.length} mã)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _vouchers.isEmpty ? AppColors.textHint : AppColors.textSecondary,
                                ),
                              ),
                  ),
                  if (_selectedVoucher != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedVoucher = null),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    )
                  else if (_vouchers.isNotEmpty)
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          if (_selectedVoucher != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Tiết kiệm ${_formatPrice(_selectedVoucher!.discountAmount)} VND',
                  style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text('Chọn mã giảm giá',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _vouchers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 48, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text('Không có voucher khả dụng', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _vouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _buildVoucherTile(_vouchers[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherTile(VoucherModel v) {
    final isSelected = _selectedVoucher?.id == v.id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedVoucher = isSelected ? null : v);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.05) : AppColors.white,
          border: Border.all(color: isSelected ? AppColors.primaryLight : AppColors.border, width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_offer, color: AppColors.primaryLight, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(v.code,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tiết kiệm ${_formatPrice(v.discountAmount)} VND',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFCC0000)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(v.discountLabel,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (v.minSpend > 0)
                    Text('Đơn tối thiểu ${_formatPrice(v.minSpend)} VND',
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  if (v.endDate != null)
                    Text('HSD: ${v.endDate}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatPrice(_finalPrice)} VND',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Đã bao gồm thuế và phí',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isBooking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Xác nhận đặt phòng',
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
}
