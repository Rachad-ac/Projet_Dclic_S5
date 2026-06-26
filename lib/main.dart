import 'package:flutter/material.dart';
import './views/redacteur_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Redacteurs',
      debugShowCheckedModeBanner: false,
      home: RedacteurInterface(),
    );
  }
}

