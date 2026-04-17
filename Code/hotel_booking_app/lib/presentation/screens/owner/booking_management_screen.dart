import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/booking/booking_model.dart';
import 'package:intl/intl.dart';

class BookingManagementScreen extends StatefulWidget {
  final String? hotelId;
  const BookingManagementScreen({super.key, this.hotelId});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Pending, Confirmed (Sắp tới), Cancelled, Checked-out (Đã xong)
  final List<String> _statuses = ["Pending", "Confirmed", "Cancelled", "Checked-out"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final hotelId = widget.hotelId ?? (provider.hotels.isNotEmpty ? provider.hotels[0].id : "");
    if (hotelId.isNotEmpty) {
      provider.fetchBookings(hotelId, status: _statuses[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final bookings = provider.bookings;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lượt đặt phòng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E5AAC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E5AAC),
          isScrollable: true,
          tabs: const [
            Tab(text: "Chờ duyệt"),
            Tab(text: "Sắp tới"),
            Tab(text: "Đã hủy"),
            Tab(text: "Đã xong"),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(bookings, "Pending"),
                _buildBookingList(bookings, "Confirmed"),
                _buildBookingList(bookings, "Cancelled"),
                _buildBookingList(bookings, "Checked-out"),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<Booking> allBookings, String status) {
    final filtered = allBookings.where((b) {
      if (status == "Confirmed") return b.status == "Confirmed" || b.status == "Checked-in";
      return b.status == status;
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: filtered.isEmpty
          ? ListView(children: const [SizedBox(height: 100), Center(child: Text("Không có đơn đặt phòng nào."))])
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildBookingCard(filtered[index]),
            ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Future: Show full detail dialog
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Đơn đặt ngày ${DateFormat('dd/MM/yyyy').format(booking.bookedAt)}", 
                    style: const TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2E5AAC).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text("ID: ${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}", style: const TextStyle(color: Color(0xFF2E5AAC), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(booking.customerInfo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 8),

              // Hiển thị Loại phòng & Số phòng (Nếu có)
              _buildModernInfoRow(booking),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tổng tiền", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text("${NumberFormat.decimalPattern('en_US').format(booking.total)} VND", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Tiền cọc", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text("${NumberFormat.decimalPattern('en_US').format(booking.depositAmount)} VND", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                    ],
                  ),
                ],
              ),
              
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeInfo("Check-In", DateFormat('dd/MM/yyyy').format(booking.checkin)),
                  const Icon(Icons.arrow_right_alt, color: Colors.grey),
                  _buildTimeInfo("Check-Out", DateFormat('dd/MM/yyyy').format(booking.checkout)),
                ],
              ),
              const SizedBox(height: 20),
              _buildActionArea(booking),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(Booking booking) {
    // Sử dụng roomTypeName từ model nếu có, hoặc lấy cái đầu tiên từ RoomTypes, hoặc fallback
    final provider = Provider.of<OwnerProvider>(context, listen: false);
    final fallbackName = provider.roomTypes.isNotEmpty ? provider.roomTypes[0].name : "Standard";
    final String roomType = booking.roomTypeName ?? (booking.bookedRooms.isNotEmpty ? booking.bookedRooms[0].roomTypeName : fallbackName);
    
    if (booking.status == "Confirmed" || booking.status == "Checked-out") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hotel, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text("Loại: $roomType", style: const TextStyle(color: Colors.black87, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.room_preferences, size: 14, color: Color(0xFF2E5AAC)),
              const SizedBox(width: 6),
              Text("Phòng: ${booking.assignedRoomNumber ?? "Chưa gán"}", 
                style: const TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      );
    } else if (booking.status == "Cancelled") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Loại đã book: $roomType", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text("Lý do: ${booking.cancellationReason ?? "Không có lý do"}", 
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      );
    } else {
      return Text("Loại: $roomType x ${booking.bookedRooms.isNotEmpty ? booking.bookedRooms[0].quantity : 1}", 
        style: const TextStyle(color: Colors.black54, fontSize: 13));
    }
  }

  Widget _buildActionArea(Booking booking) {
    if (booking.status == "Cancelled") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("Đã hủy đơn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      );
    } else if (booking.status == "Confirmed") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("Đã xác nhận", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      );
    } else if (booking.status == "Checked-out") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF2E5AAC).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("Đã hoàn thành", style: TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold))),
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRejectReasonSheet(context, booking.id),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("Từ chối", style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<OwnerProvider>(context, listen: false);
                final error = await provider.updateBookingStatus(booking.id, 'Confirmed');
                if (error != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xác nhận và tự động gán phòng!"), backgroundColor: Colors.green));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5AAC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text("Xác nhận", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTimeInfo(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showRejectReasonSheet(BuildContext context, String bookingId) {
    String selectedReason = "Hết phòng";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lý do từ chối", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 15),
              _buildRadio(setModalState, "Hết phòng", selectedReason, (val) => selectedReason = val),
              _buildRadio(setModalState, "Thanh toán không thành công", selectedReason, (val) => selectedReason = val),
              _buildRadio(setModalState, "Thông tin không hợp lệ", selectedReason, (val) => selectedReason = val),
              _buildRadio(setModalState, "Phòng đang bảo trì", selectedReason, (val) => selectedReason = val),
              _buildRadio(setModalState, "Lý do khác:", selectedReason, (val) => selectedReason = val),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Đóng sheet trước
                    final provider = Provider.of<OwnerProvider>(context, listen: false);
                    final error = await provider.updateBookingStatus(bookingId, 'Cancelled', reason: selectedReason);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5AAC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Xác nhận từ chối", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(StateSetter setState, String title, String group, Function(String) onChanged) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: title,
      groupValue: group,
      activeColor: const Color(0xFF2E5AAC),
      onChanged: (val) => setState(() => onChanged(val!)),
      contentPadding: EdgeInsets.zero,
    );
  }
}