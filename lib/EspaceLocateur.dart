import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as globals;

class EspaceLocateur extends StatefulWidget {
  final int locateurId;

  const EspaceLocateur({Key? key, required this.locateurId}) : super(key: key);

  @override
  State<EspaceLocateur> createState() => _EspaceLocateurState();
}

class _EspaceLocateurState extends State<EspaceLocateur> {
  List<dynamic> _locations = [];
  bool _isLoading = false;

  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  final List<String> _types = ["S+1", "S+2", "S+3", "S+4", "S+5"];
  String _selectedType = "S+1";

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);

    var url = Uri.parse(
      "${globals.baseUrl}api_locations.php?locateur_id=${widget.locateurId}",
    );

    var response = await http.get(url);
    var data = json.decode(response.body);

    setState(() {
      if (data["status"] == "success") {
        _locations = data["data"];
      }
      _isLoading = false;
    });
  }

  void _showAddLocationDialog() {
    _resetForm();
    showDialog(
      context: context,
      builder: (context) {
        return _buildLocationDialog(
          title: "Ajouter une location",
          onSubmit: _addLocation,
        );
      },
    );
  }

  void _showEditLocationDialog(Map<String, dynamic> location) {
    _referenceController.text = location["reference"] ?? "";
    _titreController.text = location["titre"] ?? "";
    _descriptionController.text = location["description"] ?? "";
    _adresseController.text = location["adresse"] ?? "";
    _prixController.text = location["prix_mensuel"]?.toString() ?? "";
    _selectedType = location["type_location"] ?? _types[0];

    showDialog(
      context: context,
      builder: (context) {
        return _buildLocationDialog(
          title: "Modifier la location",
          onSubmit: () => _updateLocation(location["reference"]),
        );
      },
    );
  }

  AlertDialog _buildLocationDialog({
    required String title,
    required VoidCallback onSubmit,
  }) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (title.contains("Ajouter"))
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: "Référence *",
                  border: OutlineInputBorder(),
                ),
              ),
            if (title.contains("Ajouter")) const SizedBox(height: 12),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(
                labelText: "Titre *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: "Adresse *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Prix (DT/mois) *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: "Type de location",
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(onPressed: onSubmit, child: const Text("Valider")),
      ],
    );
  }

  Future<void> _addLocation() async {
    if (_referenceController.text.isEmpty ||
        _titreController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _prixController.text.isEmpty) {
      _showSnackBar("Tous les champs * sont obligatoires");
      return;
    }

    var url = Uri.parse("${globals.baseUrl}api_locations.php");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "reference": _referenceController.text,
        "titre": _titreController.text,
        "description": _descriptionController.text,
        "adresse": _adresseController.text,
        "prix_mensuel": double.parse(_prixController.text),
        "type_location": _selectedType,
        "locateur_id": widget.locateurId,
        "action": "add",
      }),
    );

    var data = json.decode(response.body);
    if (data["status"] == "success") {
      Navigator.pop(
        context,
      ); //navigator pop permet de revenir à l'écran précédent
      _resetForm();
      _loadLocations();
      _showSnackBar("Location ajoutée !");
    } else {
      _showSnackBar("Erreur: ${data['message']}");
    }
  }

  Future<void> _updateLocation(String reference) async {
    if (_titreController.text.isEmpty ||
        _adresseController.text.isEmpty ||
        _prixController.text.isEmpty) {
      _showSnackBar("Tous les champs * sont obligatoires");
      return;
    }

    var url = Uri.parse("${globals.baseUrl}api_locations.php");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "reference": reference,
        "titre": _titreController.text,
        "description": _descriptionController.text,
        "adresse": _adresseController.text,
        "prix_mensuel": double.parse(_prixController.text),
        "type_location": _selectedType,
        "action": "update",
      }),
    );

    var data = json.decode(response.body);
    if (data["status"] == "success") {
      Navigator.pop(context);
      _resetForm();
      _loadLocations();
      _showSnackBar("Location modifiée !");
    } else {
      _showSnackBar("Erreur: ${data['message']}");
    }
  }

  Future<void> _deleteLocation(String reference) async {
    var url = Uri.parse("${globals.baseUrl}api_locations.php");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"reference": reference, "action": "delete"}),
    );

    var data = json.decode(response.body);
    if (data["status"] == "success") {
      _showSnackBar("Location supprimée !");
      _loadLocations();
    } else {
      _showSnackBar("Erreur: ${data['message']}");
    }
  }

  void _resetForm() {
    _referenceController.clear();
    _titreController.clear();
    _descriptionController.clear();
    _adresseController.clear();
    _prixController.clear();
    _selectedType = _types[0];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.grey.shade300,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16), //padding interne du container
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //pour que le texte prenne tout l espace disponible
                Expanded(
                  child: Text(
                    location["titre"] ?? "Sans titre",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
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
            const SizedBox(height: 10),
            // Adresse
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
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
            // Description
            if (location["description"] != null &&
                location["description"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  location["description"],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Badges
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.code,
                  text: location["reference"] ?? "N/A",
                  color: Colors.blue.shade200.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.apartment,
                  text: location["type_location"] ?? "N/A",
                  color: Colors.orange.shade200.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditLocationDialog(location),
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: const Text(
                    "Modifier",
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteLocation(location["reference"]),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    "Supprimer",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
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
        title: Text("Espace Locateur"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : _locations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apartment, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune location trouvée",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Appuyez sur le bouton + pour ajouter une location",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLocations,
              color: Colors.blue,
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, i) => _buildLocationCard(
                  Map<String, dynamic>.from(_locations[i]),
                ),
              ),
            ),
    );
  }
}
