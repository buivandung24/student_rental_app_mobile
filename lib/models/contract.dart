class Contract {
  final String id;
  final String roomId;
  final String tenantId;
  final String startDate; // ISO string, ví dụ "2023-01-01"
  final String endDate;
  final double deposit;
  final String status; // "active", "about_to_expire", "expired"

  Contract({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.deposit,
    required this.status,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json["id"] as String,
      roomId: json["roomId"] as String,
      tenantId: json["tenantId"] as String,
      startDate: json["startDate"] as String,
      endDate: json["endDate"] as String,
      deposit: (json["deposit"] as num).toDouble(),
      status: json["status"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "roomId": roomId,
      "tenantId": tenantId,
      "startDate": startDate,
      "endDate": endDate,
      "deposit": deposit,
      "status": status,
    };
  }
}