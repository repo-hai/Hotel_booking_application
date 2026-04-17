import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/owner_provider.dart';
import '../../../models/review/review_model.dart';
import 'package:intl/intl.dart';

class AllReviewsScreen extends StatefulWidget {
  final String hotelId;
  const AllReviewsScreen({super.key, required this.hotelId});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OwnerProvider>(context, listen: false).fetchReviews(widget.hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OwnerProvider>(context);
    final reviews = provider.reviews;
    final summary = provider.reviewSummary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Đánh giá khách hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: provider.isLoading && reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => Provider.of<OwnerProvider>(context, listen: false).fetchReviews(widget.hotelId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingSummary(summary),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Tất cả đánh giá (${summary['totalCount'] ?? reviews.length})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildReviewList(reviews),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRatingSummary(Map<String, dynamic> summary) {
    double average = double.tryParse(summary['averageRating']?.toString() ?? '0.0') ?? 0.0;
    Map<String, dynamic> rawDist = summary['distribution'] ?? {};
    int total = (summary['totalCount'] as num?)?.toInt() ?? 0;

    // Chuyển đổi distribution để hỗ trợ cả key là String và Int
    int getCount(String key) {
      // Tìm theo key là String
      if (rawDist.containsKey(key)) return (rawDist[key] as num?)?.toInt() ?? 0;
      // Tìm theo key là Int (Duyệt qua các entries để an toàn)
      final intKey = int.tryParse(key);
      if (intKey != null) {
        for (var entry in rawDist.entries) {
          if (entry.key.toString() == key) return (entry.value as num?)?.toInt() ?? 0;
        }
      }
      return 0;
    }

    double getPercent(String key) => total > 0 ? getCount(key) / total : 0.0;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Column(
            children: [
              Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star, size: 20, color: i < average.floor() ? Colors.amber : Colors.grey.shade300)),
              ),
              const SizedBox(height: 5),
              Text("Dựa trên $total đánh giá", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              children: [
                _buildStatLine("5", getPercent("5")),
                _buildStatLine("4", getPercent("4")),
                _buildStatLine("3", getPercent("3")),
                _buildStatLine("2", getPercent("2")),
                _buildStatLine("1", getPercent("1")),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatLine(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              color: const Color(0xFF2E5AAC),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Chưa có đánh giá nào.")));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final item = reviews[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.person, color: Color(0xFF2196F3)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.customerName ?? "Khách ẩn danh", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text("${item.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    Text(DateFormat('dd/MM/yyyy').format(item.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    Text(
                      item.comment.isNotEmpty ? item.comment : "Không có nhận xét.",
                      style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}