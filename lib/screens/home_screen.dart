import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
//import 'package:intelligearth_mobile/models/account_model.dart';
// import 'package:intelligearth_mobile/models/report_model.dart';
import 'package:intelligearth_mobile/screens/photo_page.dart';
import 'package:intelligearth_mobile/screens/techsupport_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Indice della pagina selezionata
  int _selectedIndex = 0;

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
      PhotoPage(),    // Usa il widget della schermata mappa
      TechsupportScreen(),    // Usa il widget della schermata report
      UserPage(user: currentUser), 
    ];
  }

  // Funzione per aggiornare la selezione dell'indice
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
                  onTap: () {
                    // Logica per aprire il menu hamburger
                  },
                  child: Image.asset(
                    'assets/icons/menu-burger.png',
                    height: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Homepage',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
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
      body: _pages[_selectedIndex],      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
            _selectedIndex == 0 ? 'assets/icons/home_selected.png' : 'assets/icons/home.png',
            height: 24,
          ),
          label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 1 ? 'assets/icons/storico_luogo_selected.png' : 'assets/icons/storico_luogo.png',
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 2 ? 'assets/icons/supporto_tecnico_selected.png' : 'assets/icons/supporto_tecnico.png',
              height: 24,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _selectedIndex == 3 ? 'assets/icons/user_selected.png' : 'assets/icons/user.png',
              height: 24,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}