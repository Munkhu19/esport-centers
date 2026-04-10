import '../models/center.dart';

final List<EsportCenter> seedCenters = [
  EsportCenter(
    id: "awp",
    name: "AWP Esport",
    address: "Гэмтлийн эмнэлэг, BGD - 31 khoroo, Ulaanbaatar 16094",
    pcCount: 40,
    pcSpec: "RTX 3060 / i5 / 16GB RAM",
    price: 3000,
    phone: "80325252",
    latitude: 47.92121806036754,
    longitude: 106.85823665412931,
    ownerEmail: "owner@awp.mn",
    lateArrivalGraceMinutes: 15,
  ),
  EsportCenter(
    id: "pro",
    name: "PRO Esport",
    address: "Бичил, WVGJ+6WX, BGD - 12 khoroo, Ulaanbaatar 16065",
    pcCount: 60,
    pcSpec: "RTX 3070 / i7",
    price: 5000,
    phone: "75351150",
    latitude: 47.92580556,
    longitude: 106.88247222,
    ownerEmail: "owner@pro.mn",
    lateArrivalGraceMinutes: 15,
  ),
];
