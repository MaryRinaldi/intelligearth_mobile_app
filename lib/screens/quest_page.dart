import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/quest_model.dart'; // Importa il modello Quest
import 'map_screen.dart';

class QuestPage extends StatelessWidget {
  QuestPage({super.key});

  final List<Quest> quests = [
    Quest(
      title: 'Quest del Colosseo',
      imagePath: 'assets/images/3D_Colosseum_quest.png',
      latitude: 41.8902,
      longitude: 12.4922,
    ),
    Quest(
      title: 'Quest della Torre di Pisa',
      imagePath: 'assets/images/3D_PisaTower_quest.png',
      latitude: 43.7229,
      longitude: 10.3966,
    ),
    // Aggiungi altre quest qui ES:
  //   Quest(
  // title: 'Quest del Vaticano',
  // imagePath: 'assets/images/3D_Vaticano_quest.png',
  // latitude: 41.9029,
  // longitude: 12.4534,
// ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          final quest = quests[index];
          return QuestBox(quest: quest);
        },
      ),
    );
  }
}

class QuestBox extends StatelessWidget {
  final Quest quest;

  const QuestBox({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              latitude: quest.latitude,
              longitude: quest.longitude,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          children: [
            Image.asset(
              quest.imagePath,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                quest.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/icons/go-to.png',
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
