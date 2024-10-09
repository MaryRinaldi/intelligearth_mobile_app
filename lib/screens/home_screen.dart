import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import 'package:intelligearth_mobile/screens/quest_page.dart';
import 'package:intelligearth_mobile/screens/reward_screen.dart';
import 'package:intelligearth_mobile/services/auth_service.dart'; // Importazione del servizio di autenticazione

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  User? currentUser; // Creazione dell'oggetto User

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
    _pages = [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Benvenuto nella Homepage!'),
            ],
          ),
        ),
      ),
      const QuestPage(),
      const RewardScreen(),
      UserPage(user: currentUser ?? User.empty()), // Gestione dell'utente corrente
    ];
  }

  Future<void> _checkIfLoggedIn() async { // Aggiunta di async qui
    bool isLoggedIn = false; // Imposta a false per testare il comportamento non loggato
    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/signin'); 
      return; // Esci dal metodo
    } 
    final authService = AuthService();

    currentUser = await AuthService.getCurrentUser(); // Metodo che recupera l'utente
    setState(() {
      _pages[3] = UserPage(user: currentUser ?? User.empty());
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_getAppBarTitle())),   
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/intelligearth_logo.png', height: 18),
                const SizedBox(width: 2),
                const Text('IntelligEarth', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],          

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

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Homepage';
      case 1:
        return 'Missioni';
      case 2:
        return 'Premi';
      case 3:
        return 'User';
      default:
        return '';
    }
  }
}
