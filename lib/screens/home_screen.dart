import 'package:flutter/material.dart';
// import 'package:intelligearth_mobile/models/account_model.dart';
// import 'package:intelligearth_mobile/models/report_model.dart';
// import 'package:intelligearth_mobile/models/user_model.dart';
// import 'package:intelligearth_mobile/screens/map_page.dart';
// import 'package:intelligearth_mobile/screens/report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  // Indice della pagina selezionata
  int _selectedIndex = 0;

  // Lista di pagine che vuoi mostrare
  static const List<Widget> _pages = <Widget>[
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Bentornat*!',
            style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
            'we are loading...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
    Center(child: Text('Mappa Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Report Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Account Page', style: TextStyle(fontSize: 24))),
  ];

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
 