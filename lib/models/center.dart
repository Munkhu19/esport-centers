class EsportCenter {
  final String id;
  final String name;
  final String address;
  final int pcCount;
  final String pcSpec;
  final int price;
  final String phone;
  final double latitude;
  final double longitude;
  final String? ownerEmail;
  final String? profileImageBase64;
  final List<String> imagesBase64;
  final int lateArrivalGraceMinutes;

  EsportCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.pcCount,
    required this.pcSpec,
    required this.price,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.ownerEmail,
    this.profileImageBase64,
    List<String>? imagesBase64,
    this.lateArrivalGraceMinutes = 15,
  }) : imagesBase64 = List<String>.unmodifiable(imagesBase64 ?? const <String>[]);

  EsportCenter copyWith({
    String? id,
    String? name,
    String? address,
    int? pcCount,
    String? pcSpec,
    int? price,
    String? phone,
    double? latitude,
    double? longitude,
    String? ownerEmail,
    String? profileImageBase64,
    List<String>? imagesBase64,
    int? lateArrivalGraceMinutes,
  }) {
    return EsportCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      pcCount: pcCount ?? this.pcCount,
      pcSpec: pcSpec ?? this.pcSpec,
      price: price ?? this.price,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      imagesBase64: imagesBase64 ?? this.imagesBase64,
      lateArrivalGraceMinutes:
          lateArrivalGraceMinutes ?? this.lateArrivalGraceMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'pcCount': pcCount,
      'pcSpec': pcSpec,
      'price': price,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'ownerEmail': ownerEmail,
      'profileImageBase64': profileImageBase64,
      'imagesBase64': imagesBase64,
      'lateArrivalGraceMinutes': lateArrivalGraceMinutes,
    };
  }

  factory EsportCenter.fromMap(Map<String, dynamic> map) {
    final rawImages = map['imagesBase64'];
    List<String> parsedImages = const <String>[];
    if (rawImages is List) {
      parsedImages = rawImages
          .whereType<Object>()
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    final legacyImage = map['imageBase64']?.toString();
    final profileImage = map['profileImageBase64']?.toString();
    return EsportCenter(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      pcCount: int.tryParse(map['pcCount'].toString()) ?? 0,
      pcSpec: map['pcSpec']?.toString() ?? '',
      price: int.tryParse(map['price'].toString()) ?? 0,
      phone: map['phone']?.toString() ?? '',
      latitude: double.tryParse(map['latitude'].toString()) ?? 0,
      longitude: double.tryParse(map['longitude'].toString()) ?? 0,
      ownerEmail: map['ownerEmail']?.toString(),
      profileImageBase64: (profileImage != null && profileImage.isNotEmpty)
          ? profileImage
          : ((legacyImage != null && legacyImage.isNotEmpty) ? legacyImage : null),
      imagesBase64: parsedImages,
      lateArrivalGraceMinutes:
          int.tryParse(map['lateArrivalGraceMinutes'].toString()) ?? 15,
    );
  }
}
