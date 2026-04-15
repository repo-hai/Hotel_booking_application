class SearchHistoryModel {
  final String city;
  final String? checkIn;
  final String? checkOut;
  final int guests;
  final int rooms;
  final String? searchedAt;

  SearchHistoryModel({
    required this.city,
    this.checkIn,
    this.checkOut,
    this.guests = 1,
    this.rooms = 1,
    this.searchedAt,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      city: json['city'] ?? '',
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      guests: json['guests'] ?? 1,
      rooms: json['rooms'] ?? 1,
      searchedAt: json['searchedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'rooms': rooms,
      'searchedAt': searchedAt,
    };
  }

  /// Hiển thị thông tin phụ: "8 - 9 Th2, 2 người lớn"
  String get subtitle {
    final parts = <String>[];
    if (checkIn != null && checkOut != null) {
      try {
        final inDate = DateTime.parse(checkIn!);
        final outDate = DateTime.parse(checkOut!);
        parts.add('${inDate.day} - ${outDate.day} Th${outDate.month}');
      } catch (_) {}
    }
    if (guests > 0) {
      parts.add('$guests người lớn');
    }
    return parts.join(', ');
  }
}
