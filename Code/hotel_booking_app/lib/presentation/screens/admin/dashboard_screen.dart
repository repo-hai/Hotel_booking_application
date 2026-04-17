import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final results = await Future.wait([
      AdminApiService.fetchDashboardStats(),
      AdminApiService.fetchRecentBookings(),
    ]);
    return _DashboardData(
      stats: results[0] as DashboardStats,
      recent: results[1] as List<RecentBooking>,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Tổng quan Admin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _buildError(snap.error.toString());
            }
            final data = snap.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(data.stats),
                  const SizedBox(height: 24),
                  _buildRecentSection(data.recent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, size: 64, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào,',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            'Admin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.people_outline,
          label: 'Tổng User',
          value: _formatCount(stats.totalUsers),
          iconBgColor: AppColors.statBlue,
          iconColor: AppColors.statIconBlue,
        ),
        _buildStatCard(
          icon: Icons.hotel_outlined,
          label: 'Khách sạn',
          value: _formatCount(stats.totalHotels),
          iconBgColor: AppColors.statGreen,
          iconColor: AppColors.statIconGreen,
        ),
        _buildStatCard(
          icon: Icons.bookmark_border,
          label: 'Đơn đặt phòng',
          value: _formatCount(stats.totalBookings),
          iconBgColor: AppColors.statOrange,
          iconColor: AppColors.statIconOrange,
        ),
        _buildStatCard(
          icon: Icons.local_offer_outlined,
          label: 'Voucher',
          value: _formatCount(stats.totalVouchers),
          iconBgColor: AppColors.statPurple,
          iconColor: AppColors.statIconPurple,
        ),
      ],
    );
  }

  String _formatCount(int n) {
    final str = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(List<RecentBooking> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đơn đặt phòng gần đây',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Chưa có đơn đặt phòng nào',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...items.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildBookingItem(b),
              )),
      ],
    );
  }

  Widget _buildBookingItem(RecentBooking booking) {
    final info = _statusInfo(booking.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.statBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hotel,
                color: AppColors.statIconBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.hotelName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.guestName} • ${booking.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              info.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: info.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String raw) {
    switch (raw.toLowerCase()) {
      case 'confirmed':
        return const _StatusInfo('Đã xác nhận', AppColors.primary);
      case 'cancelled':
        return const _StatusInfo('Đã hủy', AppColors.danger);
      case 'cancel_requested':
        return const _StatusInfo('Yêu cầu hủy', Color(0xFFFF7043));
      case 'completed':
        return const _StatusInfo('Hoàn thành', AppColors.success);
      case 'pending':
      default:
        return const _StatusInfo('Chờ xác nhận', AppColors.warning);
    }
  }
}

class _DashboardData {
  final DashboardStats stats;
  final List<RecentBooking> recent;
  _DashboardData({required this.stats, required this.recent});
}

class _StatusInfo {
  final String label;
  final Color color;
  const _StatusInfo(this.label, this.color);
}
