class Room {
  final String id;
  final String roomType;
  final double price;
  final String status;

  Room({
    required this.id,
    required this.roomType,
    required this.price,
    required this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json["id"] as String,
      roomType: json["roomType"] as String,
      price: (json["price"] as num).toDouble(),
      status: json["status"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "roomType": roomType,
      "price": price,
      "status": status,
    };
  }
}