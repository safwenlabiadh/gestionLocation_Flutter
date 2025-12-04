import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as globals;

class LoginLocateur extends StatefulWidget {
  const LoginLocateur({super.key, required this.title});
  final String title;

  @override
  State<LoginLocateur> createState() => _LoginLocateurState();
}

class _LoginLocateurState extends State<LoginLocateur> {
  final TextEditingController controllerusername = TextEditingController();
  final TextEditingController controllerpassword = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    controllerusername.dispose(); //liberer les ressources
    controllerpassword.dispose();
    super.dispose(); //appeler la methode dispose de la classe parente
  }

  Future<void> loginLocateur() async {
    if (controllerusername.text.isEmpty || controllerpassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    var url = Uri.parse("${globals.baseUrl}login.php");

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': controllerusername.text.trim(),
          'password': controllerpassword.text.trim(),
        }),
      );

      var data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie !'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(
          context,
          '/EspaceLocateur',
          arguments: {'id': data['user']['id']},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Échec connexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //scaffold permet de creer la structure de base de l application
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              "Connectez-vous en tant que locateur",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: controllerusername,
              decoration: const InputDecoration(
                labelText: "Adresse email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controllerpassword,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
              obscureText: true, //masquer le mot de passe
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: loginLocateur,
                      child: const Text("Se connecter"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
