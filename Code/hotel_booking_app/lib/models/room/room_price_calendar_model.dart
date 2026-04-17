class RoomPriceCalendar {
  final int id;
  final DateTime date;
  final int price;

  RoomPriceCalendar({required this.id, required this.date, required this.price});

  factory RoomPriceCalendar.fromJson(Map<String, dynamic> json) => RoomPriceCalendar(
        id: json['id'] ?? 0,
        date: DateTime.parse(json['date']),
        price: json['price'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'price': price,
      };
}