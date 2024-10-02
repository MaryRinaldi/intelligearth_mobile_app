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
            Image.asset('assets/images/intelligearth_logo.png', height: 50),
            Text('IntelligEarth App', style: TextStyle(fontSize: 24)),
            Text('Bentornat*!', style: TextStyle(fontSize: 24)),
            Text('we are loading...', style: TextStyle(fontSize: 18)),
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
    // Navigazione alla pagina dell'account
  if (index == 3) { // Indice della pagina Account
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPage(user: currentUser),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelligEarth'),
      ),
      body: _pages[_selectedIndex],      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mappa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
 