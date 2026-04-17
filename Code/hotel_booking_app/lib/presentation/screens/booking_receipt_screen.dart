import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking_history_model.dart';

class BookingReceiptScreen extends StatelessWidget {
  final BookingHistoryModel booking;
  const BookingReceiptScreen({super.key, required this.booking});

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

  String _formatDate(String? iso) {
    if (iso == null) return '---';
    try {
      final dt = DateTime.parse(iso);
      const weekdays = [
        'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'
      ];
      return '${weekdays[dt.weekday - 1]}, ${dt.day} Tháng ${dt.month}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  int get _nights {
    try {
      if (booking.checkIn == null || booking.checkOut == null) return 1;
      final ci = DateTime.parse(booking.checkIn!);
      final co = DateTime.parse(booking.checkOut!);
      return co.difference(ci).inDays.clamp(1, 999);
    } catch (_) {
      return 1;
    }
  }

  String get _roomSummary {
    if (booking.bookedRooms.isEmpty) return 'Phòng đã đặt';
    return booking.bookedRooms.map((r) {
      final qty = r['quantity'] ?? 1;
      final name = r['name'] ?? r['roomTypeId'] ?? 'Phòng';
      return '${qty} x $name';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final discount = booking.discount > 0
        ? booking.discount
        : booking.originalPrice - booking.total;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildHotelCard(),
                  const SizedBox(height: 12),
                  _buildSummaryCard(discount),
                  const SizedBox(height: 12),
                  _buildCustomerCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.hotelName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '8.7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (booking.hotelStar > 0)
            Row(
              children: List.generate(
                booking.hotelStar,
                (_) => const Icon(Icons.star,
                    size: 14, color: AppColors.accent),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${booking.hotelAddress}, ${booking.hotelCity}, Việt Nam',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          const Text(
            'Địa điểm rất tốt!',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhận phòng',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(booking.checkIn),
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
                    const Text('Trả phòng',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(booking.checkOut),
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

  Widget _buildSummaryCard(double discount) {
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
            '$_nights đêm, 1 phòng, 2 người lớn',
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
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          _priceRow('Giá gốc:', booking.originalPrice),
          const SizedBox(height: 6),
          _priceRow('Giảm giá người dùng mới:', -discount, isDiscount: true),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
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
                      Text(
                        '${_formatPrice(booking.originalPrice)} VND',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatPrice(booking.total)} VND',
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
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
        Text(
          '${isDiscount ? "- " : ""}${_formatPrice(amount.abs())} VND',
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? Colors.green : AppColors.textSecondary,
            fontWeight:
                isDiscount ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
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
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _infoRow('Họ tên', booking.customerName),
          _infoRow('Email', booking.customerEmail),
          _infoRow('Điện thoại', booking.customerPhone),
          _infoRow('Mã đặt phòng', '#${booking.id.substring(0, 8).toUpperCase()}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '---' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
