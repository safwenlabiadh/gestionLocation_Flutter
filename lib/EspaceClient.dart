import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as globals;

class EspaceClient extends StatefulWidget {
  const EspaceClient({super.key});

  @override
  State<EspaceClient> createState() => _EspaceClientState();
}

class _EspaceClientState extends State<EspaceClient> {
  List<dynamic> _locations = [];
  List<dynamic> _filteredLocations = [];
  bool _isLoading = true;
  String _searchText = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
      _filteredLocations = _locations.where((location) {
        final titre = (location["titre"] ?? "").toString().toLowerCase();
        final adresse = (location["adresse"] ?? "").toString().toLowerCase();
        final type = (location["type_location"] ?? "").toString().toLowerCase();
        return titre.contains(_searchText) ||
            adresse.contains(_searchText) ||
            type.contains(_searchText);
      }).toList();
    });
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);

    try {
      var url = Uri.parse("${globals.baseUrl}api_locations.php");
      var response = await http.get(url);
      var data = json.decode(response.body);

      setState(() {
        if (data["status"] == "success") {
          _locations = data["data"];
        } else {
          _locations = [];
        }
        _filteredLocations = _locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement locations: $e")),
      );
    }
  }

  String _formatPrix(dynamic prix) {
    if (prix == null) return "0 DT/mois";
    try {
      double value = prix is num
          ? prix.toDouble()
          : double.parse(prix.toString());
      return "${value.toStringAsFixed(0)} DT/mois";
    } catch (e) {
      return "$prix DT/mois";
    }
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    location["titre"] ?? "Sans titre",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _formatPrix(location["prix_mensuel"]),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Adresse
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location["adresse"] ?? "Adresse non spécifiée",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Type de location
            Row(
              children: [
                Icon(Icons.apartment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  location["type_location"] ?? "N/A",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            if (location["description"] != null &&
                location["description"].toString().isNotEmpty)
              Text(
                location["description"],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Client"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par titre, adresse ou type...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Aucune location disponible",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchLocations,
                    color: Colors.blue,
                    child: ListView.builder(
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, i) => _buildLocationCard(
                        Map<String, dynamic>.from(_filteredLocations[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
