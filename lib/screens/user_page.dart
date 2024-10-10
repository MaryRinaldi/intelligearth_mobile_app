import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/user_model.dart';

class UserPage extends StatefulWidget {
  final User user;

  const UserPage({super.key, required this.user});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  bool _isMenuVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Simuliamo un caricamento di dati
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false; // Impostiamo il caricamento a falso dopo 2 secondi
      });
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
      if (_isMenuVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Utente'),
        leading: IconButton(
          icon: const Icon(Icons.menu), // Icona del menu hamburger
          onPressed: _toggleMenu, // Mostra o nascondi il menu
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // Mostra un indicatore di caricamento
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome: ${widget.user.name}', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      Text('Email: ${widget.user.email}', style: const TextStyle(fontSize: 20)),
                      // Aggiungi ulteriori dettagli utente qui
                    ],
                  ),
                ),
          if (_isMenuVisible)
            FadeTransition(
              opacity: _animation,
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuItem('assets/icons/home_com.png', 'Homepage', 0),
                        _menuItem('assets/icons/quest.png', 'Quests', 1),
                        _menuItem('assets/icons/premi.png', 'Rewards', 2),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white),
                        _menuItem('assets/icons/settings.png', 'Impostazioni', 3),
                        _menuItem('assets/icons/404.png', 'Aiuto', 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget per ogni elemento del menu
  Widget _menuItem(String iconPath, String label, int index) {
    return GestureDetector(
      onTap: () {
        // Implementa la logica di navigazione qui
        Navigator.of(context).pushNamed('/someRoute'); // Cambia '/someRoute' con la tua route
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Image.asset(iconPath, height: 24),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
