class ReviewModel {
  final String id;
  final double rating;
  final String comment;
  final String guestName;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.guestName,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] ?? '',
      guestName: json['guestName'] ?? 'Khách ẩn danh',
      createdAt: json['createdAt'],
    );
  }
}

class HotelReviewSummary {
  final List<ReviewModel> reviews;
  final int totalReviews;
  final double averageRating;
  final Map<int, int> breakdown; // {5: count, 4: count, ...}

  HotelReviewSummary({
    required this.reviews,
    required this.totalReviews,
    required this.averageRating,
    required this.breakdown,
  });

  factory HotelReviewSummary.empty() {
    return HotelReviewSummary(
      reviews: [],
      totalReviews: 0,
      averageRating: 0,
      breakdown: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
    );
  }

  String get ratingLabel {
    if (averageRating >= 4.5) return 'Tuyệt vời';
    if (averageRating >= 4.0) return 'Rất tốt';
    if (averageRating >= 3.0) return 'Tốt';
    if (averageRating >= 2.0) return 'Dễ chịu';
    return 'Trung bình';
  }

  // Điểm trên thang 10 để hiển thị
  double get ratingOutOf10 => averageRating * 2;
}
