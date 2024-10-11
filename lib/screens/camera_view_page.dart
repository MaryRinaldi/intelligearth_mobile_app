import 'dart:io'; 
import 'package:flutter/material.dart';

class CameraViewPage extends StatelessWidget {
  final String imagePath;

  const CameraViewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizza Immagine')),
      body: Center(
        child: Image.file(File(imagePath)), // Mostra l'immagine
      ),
    );
  }
}
