import 'review_image_model.dart';

class Review {
  final String id;
  final String? customerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<ReviewImage> images;

  Review({
    required this.id,
    this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['id'] ?? json['bookingId'])?.toString() ?? '',
      customerName: json['customerName'],
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      images: (json['images'] as List? ?? [])
          .map((e) => ReviewImage.fromJson(e)).toList(),
    );
  }
}