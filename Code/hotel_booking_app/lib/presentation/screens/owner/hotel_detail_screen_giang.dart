import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/hotel/hotel_model.dart';
import 'all_reviews_screen.dart'; 
import 'booking_management_screen.dart';
import 'all_room_types_screen.dart';
import 'package:intl/intl.dart';
import '../../../models/review/review_model.dart';
import '../../../models/booking/booking_model.dart';
import '../../../models/room/room_type_model.dart';
import 'statistics_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OwnerProvider>(context, listen: false);
      provider.fetchHotelDetails(widget.hotel.id);
      provider.fetchReviews(widget.hotel.id);
      provider.fetchBookings(widget.hotel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final stats = provider.hotelStats;
    final rTypes = provider.roomTypes;
    final reviews = provider.reviews;
    final summary = provider.reviewSummary;
    final bookings = provider.bookings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.hotel.name, style: const TextStyle(color: Colors.black, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading && rTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchHotelDetails(widget.hotel.id),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHotelHeader(),
                    const SizedBox(height: 25),

                    // Stats Dashboard for this hotel
                    const SizedBox(height: 10),

                    // Section Reviews
                    _buildSectionTitle(context, "Reviews (${summary['totalCount'] ?? 0})", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AllReviewsScreen(hotelId: widget.hotel.id)));
                    }),
                    reviews.isNotEmpty 
                        ? _buildReviewPreview(reviews[0])
                        : const Text("Chưa có đánh giá nào", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 25),

                    // Section Bookings
                    _buildSectionTitle(context, "Lượt đặt phòng", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BookingManagementScreen(hotelId: widget.hotel.id)));
                    }),
                    bookings.isNotEmpty
                        ? _buildBookingPreview(bookings[0])
                        : const Text("Chưa có lượt đặt phòng nào", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 25),

                    // Section Room Types
                    _buildSectionTitle(context, "Loại phòng (${rTypes.length})", () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => AllRoomTypesScreen(hotelId: widget.hotel.id),
                          settings: const RouteSettings(name: 'AllRoomTypesScreen'),
                        )
                      );
                    }),
                    rTypes.isNotEmpty
                        ? _buildRoomTypePreview(rTypes[0])
                        : const Text("Chưa có loại phòng nào", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _miniStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13), overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onTap,
          child: const Text("Tất cả", style: TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildHotelHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              widget.hotel.images.isNotEmpty ? widget.hotel.images[0].url : 'https://via.placeholder.com/80',
              width: 70, height: 70, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hotel.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 22),
              Text(" ${widget.hotel.star}.0", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPreview(Review review) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 18, backgroundColor: Colors.blueGrey),
              const SizedBox(width: 10),
              Text(review.customerName ?? "Khách hàng", style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text("${review.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 10),
              Text(DateFormat('dd/MM').format(review.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBookingPreview(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${booking.customerInfo.name} - Đơn mới", style: const TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold)),
              Text("ID: ${booking.id.substring(0, 8)}...", style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text("${booking.total.toString()} VND", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleDate("Check-In", DateFormat('dd/MM/yyyy').format(booking.checkin)),
              const Icon(Icons.arrow_right_alt, color: Colors.grey),
              _buildSimpleDate("Check-Out", DateFormat('dd/MM/yyyy').format(booking.checkout)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDate(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        Text(date, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildRoomTypePreview(RoomType rt) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Sức chứa: ${rt.capacity} người", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                Text("${NumberFormat.decimalPattern('en_US').format(rt.price)} VND", style: const TextStyle(color: Color(0xFF2E5AAC), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              rt.images.isNotEmpty ? rt.images[0].url : 'https://via.placeholder.com/100',
              width: 80, height: 80, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.meeting_room, size: 40),
            ),
          ),
        ],
      ),
    );
  }
}