import 'hotel_image_model.dart';
import 'hotel_amenity_model.dart';

class Hotel {
  final String id;
  final String type;
  final String name;
  final String description;
  final String telephone;
  final String location;
  final String email;
  final int star;
  
  // Các mối quan hệ từ sơ đồ
  final List<HotelImage> images;
  final List<HotelAmenity> amenities;

  Hotel({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.telephone,
    required this.location,
    required this.email,
    required this.star,
    this.images = const [],
    this.amenities = const [],
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: (json['id'] ?? json['ID'])?.toString() ?? '',
      type: json['type'] ?? 'Khách sạn',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      telephone: json['telephone'] ?? '',
      location: json['location'] ?? ((json['address'] != null && json['city'] != null && json['address'].toString().isNotEmpty)
          ? "${json['address']}, ${json['city']}"
          : (json['city'] ?? '')),
      email: json['email'] ?? '',
      star: json['star'] is int ? json['star'] : int.tryParse(json['star']?.toString() ?? '0') ?? 0,
      // Map list images (Hỗ trợ cả List<String> từ Firestore và List<Map> cũ)
      images: (json['images'] as List? ?? [])
          .map((i) {
            if (i is String) return HotelImage(id: '', url: i);
            return HotelImage.fromJson(i);
          })
          .toList(),
      // Map list amenities
      amenities: (json['amenities'] as List? ?? [])
          .map((a) => HotelAmenity.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id) ?? id,
      'type': type,
      'name': name,
      'description': description,
      'telephone': telephone,
      'location': location,
      'email': email,
      'star': star,
      'images': images.map((i) => i.toJson()).toList(),
      'amenities': amenities.map((a) => a.toJson()).toList(),
    };
  }
}