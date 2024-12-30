import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import 'package:intelligearth_mobile/screens/quest_page.dart';
import 'package:intelligearth_mobile/screens/reward_screen.dart';
import 'package:intelligearth_mobile/services/auth_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  User? currentUser;
  bool _isMenuVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
    _controller = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_animation);

    _pages = [
      const _DashboardPage(),
      const QuestPage(),
      const RewardScreen(),
      UserPage(user: currentUser ?? User.empty()),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      _isMenuVisible = false;
      _controller.reverse();
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

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Quests';
      case 2:
        return 'Rewards';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
          if (_isMenuVisible) _buildMenu(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      title: _getAppBarTitle(),
      automaticallyImplyLeading: _selectedIndex == 3,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 26),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/intelligearth_logo.png',
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  'IntelligEarth',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppTheme.softShadow,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 26),
                        child: Text(
                          currentUser?.name.substring(0, 1).toUpperCase() ??
                              'U',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser?.name ?? 'User',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              currentUser?.email ?? 'email@example.com',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.neutralColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                    children: [
                      _buildMenuItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        route: '/home',
                      ),
                      _buildMenuItem(
                        icon: Icons.explore_rounded,
                        label: 'Quests',
                        route: '/quests',
                      ),
                      _buildMenuItem(
                        icon: Icons.emoji_events_rounded,
                        label: 'Rewards',
                        route: '/rewards',
                      ),
                      _buildMenuItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        route: '/user',
                      ),
                      const Divider(
                          indent: AppTheme.spacingLarge,
                          endIndent: AppTheme.spacingLarge),
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        route: '/settings',
                      ),
                      _buildMenuItem(
                        icon: Icons.help_rounded,
                        label: 'Help',
                        route: '/help',
                      ),
                    ],
                  ),
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  onTap: _logout,
                  color: AppTheme.errorColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? route,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              _toggleMenu();
              Navigator.pushNamed(context, route!);
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLarge,
            vertical: AppTheme.spacingMedium,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ?? AppTheme.darkColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color ?? AppTheme.darkColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      (icon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.explore_rounded, label: 'Quests'),
      (icon: Icons.emoji_events_rounded, label: 'Rewards'),
      (icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.softShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onItemTapped(index),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                    child: AnimatedContainer(
                      duration: AppTheme.animationFast,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 26)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.neutralColor,
                            size: 24,
                          ),
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            item.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.neutralColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        _buildWelcomeCard(context),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildCommunityHighlights(context),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildLeaderboard(context),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildRecentActivity(context),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Highlights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Join 1,234 active members in your area!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 230),
                ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/quests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
                child: const Text('Join Quest'),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/community'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 26),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLarge,
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
                child: const Text('View Community'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHighlights(BuildContext context) {
    final highlights = [
      (
        icon: Icons.group_rounded,
        label: 'Active Members',
        value: '1,234',
        trend: '+12% this week'
      ),
      (
        icon: Icons.photo_camera_rounded,
        label: 'Photos Shared',
        value: '5,678',
        trend: '+89 today'
      ),
      (
        icon: Icons.location_on_rounded,
        label: 'Locations Mapped',
        value: '890',
        trend: '+15 this week'
      ),
      (
        icon: Icons.eco_rounded,
        label: 'Trees Planted',
        value: '456',
        trend: '+23 this month'
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacingMedium,
      crossAxisSpacing: AppTheme.spacingMedium,
      children: highlights.map((stat) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat.icon,
                color: AppTheme.primaryColor,
                size: 32,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                stat.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                stat.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXSmall),
              Text(
                stat.trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    final topUsers = [
      LeaderboardUser(
        name: 'Maria R.',
        points: '2,450',
        avatar: 'MR',
        position: '1',
        isCurrentUser: true,
      ),
      LeaderboardUser(
        name: 'Alex K.',
        points: '2,380',
        avatar: 'AK',
        position: '2',
      ),
      LeaderboardUser(
        name: 'Sara M.',
        points: '2,310',
        avatar: 'SM',
        position: '3',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Contributors',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        ...topUsers.map((user) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: user.isCurrentUser
                  ? AppTheme.primaryColor.withValues(alpha: 26)
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: user.isCurrentUser
                        ? AppTheme.primaryColor
                        : AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#${user.position}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: user.isCurrentUser
                      ? AppTheme.primaryColor.withValues(alpha: 26)
                      : AppTheme.accentColor.withValues(alpha: 26),
                  child: Text(
                    user.avatar,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: user.isCurrentUser
                              ? AppTheme.primaryColor
                              : AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        '${user.points} points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.neutralColor,
                            ),
                      ),
                    ],
                  ),
                ),
                if (user.isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical: AppTheme.spacingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      'You',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      (
        icon: Icons.photo_camera_rounded,
        title: 'New Quest Completed',
        subtitle: 'by Maria R. • Colosseum Quest',
        time: '2h ago',
        color: AppTheme.successColor
      ),
      (
        icon: Icons.emoji_events_rounded,
        title: 'New Achievement',
        subtitle: 'Alex K. earned Explorer Badge',
        time: '5h ago',
        color: AppTheme.warningColor
      ),
      (
        icon: Icons.location_on_rounded,
        title: 'Popular Location',
        subtitle: '5 members visited Roman Forum',
        time: '1d ago',
        color: AppTheme.accentColor
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        ...activities.map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: activity.color.withValues(alpha: 26),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          activity.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.neutralColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity.time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralColor,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class LeaderboardUser {
  final String name;
  final String points;
  final String avatar;
  final String position;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.name,
    required this.points,
    required this.avatar,
    required this.position,
    this.isCurrentUser = false,
  });
}
