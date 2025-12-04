import 'package:flutter/material.dart';
import 'package:gestion_location/EspaceClient.dart';
import 'package:gestion_location/EspaceLocateur.dart';
import 'package:gestion_location/LoginLocateur.dart';
import 'package:gestion_location/HomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Location',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const Homepage(title: 'Accueil'),
        '/loginLocateur': (context) =>
            const LoginLocateur(title: 'Login Locateur'),
        '/EspaceLocateur': (context) => const EspaceLocateur(
          locateurId: 1,
        ), // IMPORTANT : plus de paramètres ici
        '/EspaceClient': (context) => const EspaceClient(),
      },
    );
  }
}
