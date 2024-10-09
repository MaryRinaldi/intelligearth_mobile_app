import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import 'package:intelligearth_mobile/screens/quest_page.dart';
import 'package:intelligearth_mobile/screens/reward_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isMenuVisible = false;

  // Creazione dell'oggetto User
  User currentUser = User(
    id: '1',
    name: 'Mario Rossi',
    email: 'mario.rossi@example.com',
    avatarUrl: '',  // Aggiungi un URL dell'avatar
    role: '',  // Aggiungi un ruolo utente o admin
  );

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _pages = [
      Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

            ],
          ),
        ),
      ),
      QuestPage(),    
      RewardScreen(),   
      UserPage(user: currentUser), 
    ];
  }

  // Funzione per mostrare/nascondere il menu hamburger
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

  // Navigazione tramite menu hamburger
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
      _toggleMenu();  // Chiudi il menu dopo aver navigato
    });
  }

  // Funzione per aggiornare la selezione dell'indice nella navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _toggleMenu,  // Mostra o nascondi il menu hamburger
                  child: Image.asset(
                    'assets/icons/ham-menu.png',
                    height: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _selectedIndex == 0 ? Center(
                child: Text(
                  'Homepage',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
            ): _selectedIndex == 1 ? Center(
                child: Text(
                  'Missioni',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
            ): _selectedIndex == 2 ? Center(
                child: Text(
                  'Premi',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                ): _selectedIndex == 3 ? Center(
                child: Text(
                  'User',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                ): Center(
                  child: Text(
                    '',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  )
                ),
            ),                
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/intelligearth_logo.png', height: 18),
                    const SizedBox(width: 2),
                    const Text('IntelligEarth', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Corpo della pagina
      body: Stack(
        children: [
          _pages[_selectedIndex],  // Pagina selezionata

          // Overlay per il menu hamburger
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
                        _menuItem('assets/icons/prof_ut.png', 'Account Utente', 3),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white),
                        _menuItem('assets/icons/settings.png', 'Impostazioni', 4),
                        _menuItem('assets/icons/404.png', 'Aiuto', 5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Bottom Navigation Bar (navbar)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 0 ? 'assets/icons/home_com.png' : 'assets/icons/home_com.png',
              height: 34,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1 ? 'assets/icons/quest.png' : 'assets/icons/quest.png',
              height: 34,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2 ? 'assets/icons/premi.png' : 'assets/icons/premi.png',
              height: 34,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3 ? 'assets/icons/prof_ut.png' : 'assets/icons/prof_ut.png',
              height: 34,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Widget per ogni elemento del menu
  Widget _menuItem(String iconPath, String label, int index) {
    return GestureDetector(
      onTap: () {
        switch (index) {
        case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
        case 1:
        Navigator.pushReplacementNamed(context, '/quests');
        break;
        case 2:
        Navigator.pushReplacementNamed(context, '/rewards');
        break;
        case 3:
        Navigator.pushReplacementNamed(context, '/user');
        break;
        default:
        Navigator.pushReplacementNamed(context, '/');
      }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Image.asset(iconPath, height: 24, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
