import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import 'package:intelligearth_mobile/screens/quest_page.dart';
import 'package:intelligearth_mobile/screens/reward_screen.dart';
import 'package:intelligearth_mobile/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  User? currentUser;
  bool _isMenuVisible = false; // Variabile per la visibilità del menu
  late AnimationController _controller;
  late Animation<double> _animation;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

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
      QuestPage(),
      const RewardScreen(),
      UserPage(user: currentUser ?? User.empty()),
    ];
  }

  Future<void> _checkIfLoggedIn() async {
    final currentUser = await AuthService().getCurrentUser();
    if (currentUser == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }
    if (!mounted) return;
    setState(() {
      this.currentUser = currentUser;
      _pages[3] = UserPage(user: currentUser);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isMenuVisible = false; // Nascondi il menu quando si cambia pagina
      _controller.reverse(); // Nascondi l'animazione del menu
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
      if (_isMenuVisible) {
        _controller.forward(); // Mostra il menu
      } else {
        _controller.reverse(); // Nascondi il menu
      }
    });
  }

  Future<void> _logout() async {
    await AuthService().signOut(); 
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin'); // Reindirizza alla pagina di accesso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(_getAppBarTitle())),
        leading: _selectedIndex == 3 // Menu hamburger solo per UserPage
            ? IconButton(
                icon: Image.asset('assets/icons/ham-menu.png'),
                onPressed: _toggleMenu, // Toggle menu visibile
              )
            : null,
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
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_isMenuVisible) // Mostra il menu solo se è visibile
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
                        _menuItem('assets/icons/home_com.png', 'Homepage', '/home'),
                        _menuItem('assets/icons/quest.png', 'Quests', '/quests'),
                        _menuItem('assets/icons/premi.png', 'Rewards', '/rewards'),
                        _menuItem('assets/icons/prof_ut.png', 'User', '/user'),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white),
                        _menuItem('assets/icons/service.png', 'Settings', '/settings'),
                        _menuItem('assets/icons/info.png', 'Help', '/help'),
                        const Spacer(),
                        _menuItemLogout('assets/icons/logout.png', 'Logout'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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
  Widget _menuItem(String iconPath, String label, String route) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMenuVisible = false; // Nascondi il menu
          _controller.reverse();
        });
        Navigator.of(context).pushNamed(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Image.asset(iconPath, height: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Widget per l'elemento di logout
  Widget _menuItemLogout(String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        _logout();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Image.asset(iconPath, height: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Color.fromARGB(255, 131, 69, 238), fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Homepage';
      case 1:
        return 'Quests';
      case 2:
        return 'Rewards';
      case 3:
        return 'Userpage';
      case 4:
        return 'Settings';
      case 5:
        return 'Help';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Pulisci l'AnimationController
    super.dispose();
  }
}
