import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/centers.dart';
import '../models/center.dart';
import '../widgets/language_toggle_button.dart';
import 'center_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EsportCenter> filteredCenters = centers;

  void searchCenter(String query) {
    final q = query.toLowerCase().trim();
    final results = centers.where((center) {
      return center.name.toLowerCase().contains(q) ||
          center.address.toLowerCase().contains(q);
    }).toList();

    setState(() {
      filteredCenters = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.centersTitle),
        actions: [
          const LanguageToggleButton(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: searchCenter,
              decoration: InputDecoration(
                hintText: l10n.searchCenterHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredCenters.isEmpty
                ? Center(
                    child: Text(
                      l10n.noCentersFound,
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCenters.length,
                    itemBuilder: (context, index) {
                      final center = filteredCenters[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(center.name),
                          subtitle: Text(center.address),
                          trailing: Text("${center.price}₮"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CenterDetail(center: center),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
