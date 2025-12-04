import 'package:flutter/material.dart';
import 'package:gestion_location/EspaceClient.dart';
import 'package:gestion_location/LoginLocateur.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.title});
  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //scaffold permet de creer la structure de base de l application
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Choisissez votre espace',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // BOUTON ESPACE CLIENT
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EspaceClient(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person, size: 30),
                  label: const Text(
                    "Espace Client",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // BOUTON ESPACE LOCATEUR
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoginLocateur(title: 'Espace Locateur'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.business, size: 30),
                  label: const Text(
                    "Espace Locateur",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Texte informatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Client : Recherchez et réservez des locations\n"
                  "Locateur : Gérez vos biens et réservations",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
