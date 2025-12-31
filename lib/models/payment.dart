class Payment {
  final String id;
  final String contractId;
  final double amount;
  final String date;
  final String note;

  Payment({
    required this.id,
    required this.contractId,
    required this.amount,
    required this.date,
    required this.note,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json["id"] as String,
      contractId: json["contractId"] as String,
      amount: (json["amount"] as num).toDouble(),
      date: json["date"] as String,
      note: json["note"] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "contractId": contractId,
      "amount": amount,
      "date": date,
      "note": note,
    };
  }
}