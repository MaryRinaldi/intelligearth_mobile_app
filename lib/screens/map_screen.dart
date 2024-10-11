import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_view_page.dart'; // Assicurati di importare la tua pagina

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // Controlla se il widget è ancora montato
    if (!context.mounted) return;

    if (pickedFile != null) {
      // Naviga alla pagina di visualizzazione dell'immagine
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraViewPage(imagePath: pickedFile.path),
        ),
      );
    } else {
      // Gestisci il caso in cui l'utente annulla l'azione
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna immagine selezionata.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mappa")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latitudine: $latitude, Longitudine: $longitude"),
            const SizedBox(height: 20), // Spazio tra il testo e il pulsante
            ElevatedButton(
              onPressed: () => _openCamera(context), // Chiama la funzione quando si preme il pulsante
              child: const Text('Apri Fotocamera'),
            ),
          ],
        ),
      ),
    );
  }
}
