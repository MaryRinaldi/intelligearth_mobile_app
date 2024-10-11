import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_view_page.dart'; 
import 'quest_page.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.questTitle, // Ricevi anche il titolo della quest
  });

  final double latitude;
  final double longitude;
  final String questTitle; // Aggiungi una variabile per il titolo

  Future<void> _openCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (!context.mounted) return;

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraViewPage(imagePath: pickedFile.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna immagine selezionata.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Naviga a QuestPage solo se non è presente nello stack
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuestPage()),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/icons/quest.png',
                  height: 50, 
                  width: 50,
                ),
              ),
            ),
            const SizedBox(width: 8), // Spazio tra l'icona e il testo
            const Text(
              'Go back to other quests',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200), // Stile del testo
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$questTitle:', // Visualizza il titolo della quest
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Latitudine: $latitude, Longitudine: $longitude"),
            const SizedBox(height: 20), 
            GestureDetector(
              onTap: () => _openCamera(context),
              child: Image.asset(
                'assets/icons/camera.png', 
                height: 50, 
                width: 50, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
