class BookingRecord {
  final String id;
  final String centerId;
  final String centerName;
  final String customerName;
  final String phone;
  final int durationHours;
  final int pricePerHour;
  final int totalPrice;
  final List<int> seatIndexes;
  final DateTime startAt;
  final DateTime createdAt;
  final String? createdByUid;
  final String? createdByEmail;
  final bool isCanceled;
  final DateTime? canceledAt;

  const BookingRecord({
    required this.id,
    required this.centerId,
    required this.centerName,
    required this.customerName,
    required this.phone,
    required this.durationHours,
    required this.pricePerHour,
    required this.totalPrice,
    required this.seatIndexes,
    required this.startAt,
    required this.createdAt,
    this.createdByUid,
    this.createdByEmail,
    this.isCanceled = false,
    this.canceledAt,
  });

  DateTime get endAt => startAt.add(Duration(hours: durationHours));

  BookingRecord copyWith({
    bool? isCanceled,
    DateTime? canceledAt,
  }) {
    return BookingRecord(
      id: id,
      centerId: centerId,
      centerName: centerName,
      customerName: customerName,
      phone: phone,
      durationHours: durationHours,
      pricePerHour: pricePerHour,
      totalPrice: totalPrice,
      seatIndexes: seatIndexes,
      startAt: startAt,
      createdAt: createdAt,
      createdByUid: createdByUid,
      createdByEmail: createdByEmail,
      isCanceled: isCanceled ?? this.isCanceled,
      canceledAt: canceledAt ?? this.canceledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'centerId': centerId,
      'centerName': centerName,
      'customerName': customerName,
      'phone': phone,
      'durationHours': durationHours,
      'pricePerHour': pricePerHour,
      'totalPrice': totalPrice,
      'seatIndexes': seatIndexes,
      'startAt': startAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdByUid': createdByUid,
      'createdByEmail': createdByEmail,
      'isCanceled': isCanceled,
      'canceledAt': canceledAt?.toIso8601String(),
    };
  }

  factory BookingRecord.fromMap(Map<String, dynamic> map) {
    final rawSeats = map['seatIndexes'];
    final seats = rawSeats is List
        ? rawSeats.map((e) => int.tryParse(e.toString()) ?? 0).toList()
        : <int>[];
    final rawStartAt = map['startAt']?.toString();
    final rawCreatedAt = map['createdAt']?.toString();
    final rawCanceledAt = map['canceledAt']?.toString();
    final parsedCreatedAt = rawCreatedAt == null
        ? DateTime.now()
        : DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    final parsedStartAt = rawStartAt == null
        ? parsedCreatedAt
        : DateTime.tryParse(rawStartAt) ?? parsedCreatedAt;

    return BookingRecord(
      id: map['id']?.toString() ?? '',
      centerId: map['centerId']?.toString() ?? '',
      centerName: map['centerName']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      durationHours: int.tryParse(map['durationHours'].toString()) ?? 0,
      pricePerHour: int.tryParse(map['pricePerHour'].toString()) ?? 0,
      totalPrice: int.tryParse(map['totalPrice'].toString()) ?? 0,
      seatIndexes: seats,
      startAt: parsedStartAt,
      createdAt: parsedCreatedAt,
      createdByUid: map['createdByUid']?.toString(),
      createdByEmail: map['createdByEmail']?.toString(),
      isCanceled: map['isCanceled'] == true,
      canceledAt: rawCanceledAt == null
          ? null
          : DateTime.tryParse(rawCanceledAt),
    );
  }
}
