import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đơn #${_shortId(booking.id)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 14),
            _buildHotelInfoCard(),
            const SizedBox(height: 14),
            _buildGuestInfoCard(),
            const SizedBox(height: 14),
            _buildBookingDetailsCard(),
            const SizedBox(height: 14),
            _buildPaymentCard(),
            if (booking.cancellationReason != null ||
                booking.adminNote != null) ...[
              const SizedBox(height: 14),
              _buildNotesCard(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) {
    if (id.length <= 6) return id;
    return id.substring(0, 6).toUpperCase();
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: booking.statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: booking.statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: booking.statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(booking.statusIcon,
                color: booking.statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.statusLabel,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: booking.statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Đặt lúc: ${BookingModel.formatDate(booking.createdAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '#${_shortId(booking.id)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelInfoCard() {
    return _buildCard(
      title: 'Thông tin chỗ nghỉ',
      icon: Icons.hotel_outlined,
      child: Column(
        children: [
          _buildDetailRow('Khách sạn',
              booking.hotelName.isEmpty ? '—' : booking.hotelName),
          _buildDetailRow('Mã khách sạn',
              booking.hotelId.isEmpty ? '—' : booking.hotelId),
          if (booking.bookedRooms.isNotEmpty)
            ...booking.bookedRooms.map((r) => _buildDetailRow(
                  'Phòng',
                  '${r.quantity} x ${r.roomName ?? r.roomTypeId} (${_formatNumber(r.price)}đ)',
                )),
        ],
      ),
    );
  }

  Widget _buildGuestInfoCard() {
    return _buildCard(
      title: 'Thông tin khách hàng',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildDetailRow(
              'Họ và tên',
              booking.customerName.isEmpty
                  ? 'Khách ẩn danh'
                  : booking.customerName),
          _buildDetailRow(
              'Số điện thoại',
              booking.customerPhone.isEmpty
                  ? 'Chưa cập nhật'
                  : booking.customerPhone),
          _buildDetailRow('Email',
              booking.customerEmail.isEmpty ? '—' : booking.customerEmail),
          if (booking.customerCountry.isNotEmpty)
            _buildDetailRow('Quốc gia', booking.customerCountry),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return _buildCard(
      title: 'Chi tiết đặt phòng',
      icon: Icons.calendar_month_outlined,
      child: Column(
        children: [
          _buildDetailRow(
              'Nhận phòng', BookingModel.formatDate(booking.checkIn)),
          _buildDetailRow(
              'Trả phòng', BookingModel.formatDate(booking.checkOut)),
          _buildDetailRow('Số đêm', '${booking.nights} đêm'),
          _buildDetailRow('Tổng số phòng', '${booking.roomCount} phòng'),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _buildCard(
      title: 'Thanh toán',
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          _buildDetailRow('Giá gốc', booking.formattedOriginal),
          if (booking.discount > 0)
            _buildDetailRow('Giảm giá', '-${booking.formattedDiscount}',
                valueColor: AppColors.success),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Divider(
                color: AppColors.textSecondary.withOpacity(0.1), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  booking.formattedTotal,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildCard(
      title: 'Ghi chú hủy đơn',
      icon: Icons.note_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.cancellationReason != null &&
              booking.cancellationReason!.isNotEmpty)
            _buildDetailRow('Lý do khách', booking.cancellationReason!),
          if (booking.adminNote != null && booking.adminNote!.isNotEmpty)
            _buildDetailRow('Ghi chú admin', booking.adminNote!),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
