class BookedRoom {
  final String id;
  final String roomTypeName;
  final int quantity;
  final int price; // Giá tại thời điểm đặt

  BookedRoom({
    required this.id, 
    required this.roomTypeName, 
    this.quantity = 1,
    required this.price
  });

  factory BookedRoom.fromJson(Map<String, dynamic> json) => BookedRoom(
    id: (json['roomTypeId'] ?? json['id'])?.toString() ?? '',
    roomTypeName: json['roomTypeName'] ?? 'Hạng phòng',
    quantity: json['quantity'] ?? 1,
    price: json['price'] ?? 0,
  );
}