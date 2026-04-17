class HotelImage {
  final String id;
  final String url;

  HotelImage({
    required this.id,
    required this.url,
  });

  factory HotelImage.fromJson(Map<String, dynamic> json) {
    return HotelImage(
      id: json['id']?.toString() ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
  };
}