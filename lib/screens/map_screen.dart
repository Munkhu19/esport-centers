import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import '../data/centers.dart';
import '../widgets/language_toggle_button.dart';
import 'center_detail.dart';

class CenterMapScreen extends StatelessWidget {
  const CenterMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        backgroundColor: Colors.orange,
        actions: const [LanguageToggleButton()],
      ),
      body: fm.FlutterMap(
        options: fm.MapOptions(
          initialCenter: LatLng(centers.first.latitude, centers.first.longitude),
          initialZoom: 13,
        ),
        children: [
          fm.TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.pc_app',
          ),
          fm.MarkerLayer(
            markers: centers
                .map(
                  (center) => fm.Marker(
                    point: LatLng(center.latitude, center.longitude),
                    width: 120,
                    height: 90,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CenterDetail(center: center),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              center.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
