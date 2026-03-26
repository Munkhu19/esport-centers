class OwnerApplication {
  const OwnerApplication({
    required this.email,
    required this.centerName,
    required this.phone,
    required this.address,
    required this.contactLink,
    required this.note,
    required this.requestedAt,
  });

  final String email;
  final String centerName;
  final String phone;
  final String address;
  final String contactLink;
  final String note;
  final DateTime requestedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'centerName': centerName,
      'phone': phone,
      'address': address,
      'contactLink': contactLink,
      'note': note,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }

  factory OwnerApplication.fromJson(Map<String, dynamic> json) {
    return OwnerApplication(
      email: (json['email'] ?? '').toString(),
      centerName: (json['centerName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      contactLink: (json['contactLink'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      requestedAt:
          DateTime.tryParse((json['requestedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
