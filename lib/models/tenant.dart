class Tenant {
  final String id;
  final String fullName;
  final String contact;

  Tenant({
    required this.id,
    required this.fullName,
    required this.contact,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json["id"] as String,
      fullName: json["fullName"] as String,
      contact: json["contact"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "contact": contact,
    };
  }
}