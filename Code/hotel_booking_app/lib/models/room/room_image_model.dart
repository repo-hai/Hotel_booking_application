class RoomImage {
  final String id;
  final String url;

  RoomImage({required this.id, required this.url});

  factory RoomImage.fromJson(Map<String, dynamic> json) => RoomImage(
        id: json['id']?.toString() ?? '',
        url: json['url'] ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}