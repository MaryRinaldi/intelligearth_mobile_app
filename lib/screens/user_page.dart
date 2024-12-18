import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({super.key, required this.user});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  final int maxImages = 5; // Numero massimo di immagini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informazioni utente
              Text('Nome: ${widget.user.name}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text('Email: ${widget.user.email}',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // Sezione 1: Quest a cui vuoi partecipare
              const Text(
                'Quest a cui vuoi partecipare',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildImageRow(),

              const SizedBox(height: 20),

              // Sezione 2: Rewards ottenuti fin'ora
              const Text(
                'Rewards ottenuti fin\'ora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildImageRow(),

              const SizedBox(height: 20),

              // Sezione 3: Edifici che hai visitato
              const Text(
                'Edifici che hai visitato',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildImageRow(),
            ],
          ),
        ),
      ),
    );
  }

  // Funzione per costruire la riga delle immagini con l'icona sovrapposta
  Widget _buildImageRow() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Carosello delle immagini
        SizedBox(
          height: 150, // Imposta l'altezza per le slide
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: maxImages,
            itemBuilder: (context, index) {
              return _buildSlide(
                  'assets/images/intelligearth_logo.png', 'Elemento $index');
            },
          ),
        ),
        // Icona per scorrere a destra
        Positioned(
          right: 0, // Posiziona l'icona a destra
          child: GestureDetector(
            onTap: () {
              // Azione da eseguire quando l'icona viene premuta
              // Qui puoi aggiungere logica per cambiare pagina se necessario
            },
            child: Image.asset(
              'assets/icons/slideright.png', // Icona per scorrere verso destra
              height: 25, // Altezza dell'icona
              width: 25, // Larghezza dell'icona
            ),
          ),
        ),
      ],
    );
  }

  // Funzione per creare una singola slide con immagine
  Widget _buildSlide(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(4.0),
      width: 100, // Larghezza del box uguale alla larghezza dell'immagine
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Color.fromRGBO(0, 0, 0, 0.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Immagine del logo
          Image.asset(
            imagePath,
            width: 80, // Dimensione dell'immagine
            height: 80,
          ),
          const SizedBox(height: 5), // Spazio tra l'immagine e il testo
          // Testo della slide
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
