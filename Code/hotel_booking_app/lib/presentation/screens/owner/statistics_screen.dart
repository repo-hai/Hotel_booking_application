import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/network_image_with_placeholder.dart';
import 'owner_account_screen.dart';
import 'owner_home_screen.dart';
import '../profile_view.dart';

class StatisticsScreen extends StatefulWidget {
  final Hotel? hotel;
  const StatisticsScreen({super.key, this.hotel});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showResult = false;
  Map<String, dynamic> _localStats = {};

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2E5AAC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _showResult = false; // Reset results if dates change
      });
    }
  }

  Future<void> _fetchStatistics() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc")),
      );
      return;
    }

    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final hotelId = widget.hotel?.id ?? (provider.hotels.isNotEmpty ? provider.hotels[0].id : "");
    
    if (hotelId.isNotEmpty) {
      final stats = await provider.fetchHotelStatistics(
        hotelId,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      );
      setState(() {
        _localStats = stats;
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final currentHotel = widget.hotel ?? (provider.hotels.isNotEmpty ? provider.hotels[0] : null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_showResult) {
              setState(() => _showResult = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text("Thống kê doanh thu", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: currentHotel == null 
          ? const Center(child: Text("Không tìm thấy dữ liệu khách sạn."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHotelHeader(currentHotel),
                  const SizedBox(height: 30),
                  
                  const Text("Chọn thời gian thống kê", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: _buildDateBox(
                            label: "Ngày bắt đầu", 
                            value: _startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : "dd/mm/yyyy", 
                            isActive: true
                          ),
                        )
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: _buildDateBox(
                            label: "Ngày kết thúc", 
                            value: _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : "dd/mm/yyyy", 
                            isActive: true
                          ),
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  if (_showResult) 
                    _buildStatisticsResults(_localStats) 
                  else 
                    _buildActionCenter(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E5AAC),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
            (route) => false,
          );
        } else if (index == 1 && _showResult) {
          setState(() => _showResult = false);
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView(isOwner: true)));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Thống kê"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Tin nhắn"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }

  Widget _buildHotelHeader(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          NetworkImageWithPlaceholder(
            url: hotel.images.isNotEmpty ? hotel.images[0].url : null,
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(10),
            placeholderIcon: Icons.hotel,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({required String label, required String value, required bool isActive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF2E5AAC)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2E5AAC).withValues(alpha: 0.1)),
          ),
          child: Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildActionCenter() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _fetchStatistics,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5AAC),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text("Xem thống kê", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatisticsResults(Map<String, dynamic> stats) {
    final currencyFormat = NumberFormat.decimalPattern('en_US');
    return Column(
      children: [
        _buildStatCard("TỔNG DOANH THU", "${currencyFormat.format(stats['totalRevenue'] ?? 0)} VND", Icons.account_balance_wallet_outlined),
        _buildStatCard("TỔNG SỐ ĐƠN ĐẶT", "${currencyFormat.format(stats['totalBookings'] ?? 0)} đơn", Icons.confirmation_number_outlined),
        if ((stats['totalBookings'] ?? 0) > 0)
          _buildStatCard(
            "LOẠI PHÒNG ĐẶT NHIỀU NHẤT", 
            "${stats['mostPopularRoom'] ?? 'Phòng Standard'}", 
            Icons.star_outline,
            subValue: stats['mostPopularRoomCount'] != null ? "${stats['mostPopularRoomCount']} lượt đặt" : null
          ),
        const SizedBox(height: 20),
        const Text("Dữ liệu được cập nhật từ hệ thống", style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatCard(String title, String mainValue, IconData icon, {String? subValue}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(mainValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E5AAC)), overflow: TextOverflow.ellipsis)),
              if (subValue != null)
                Text(subValue, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}