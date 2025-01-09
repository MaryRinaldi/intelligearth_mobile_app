import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/screens/user_page.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import 'package:intelligearth_mobile/screens/quest_page.dart';
import 'package:intelligearth_mobile/screens/reward_screen.dart';
import 'package:intelligearth_mobile/services/auth_service.dart';
import 'package:intelligearth_mobile/screens/settings_page.dart';
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
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  List<Widget> get _pages => [
        _DashboardPage(
            onNavigateToQuests: () => _onItemTapped(1),
            onNavigateToRewards: () => _onItemTapped(2)),
        const QuestPage(),
        const RewardScreen(),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          UserPage(user: currentUser ?? User.empty()),
      ];

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_animation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkIfLoggedIn() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }
    if (!mounted) return;
    setState(() {
      currentUser = user;
      _isLoading = false;
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
              if (_selectedIndex == 3 && _isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
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
        if (_selectedIndex != 3)
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 30),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/intelligearth_logo.png',
                    height: 34,
                  ),
                  const SizedBox(width: AppTheme.spacingXSmall),
                ],
              ),
            ),
          ),
        if (_selectedIndex == 3)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _toggleMenu,
            color: AppTheme.darkColor,
            iconSize: 34,
            padding: const EdgeInsets.only(right: AppTheme.spacingLarge),
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
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: AppTheme.lightColor.withValues(alpha: 15),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 155),
              width: 1,
            ),
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
                            AppTheme.primaryColor.withValues(alpha: 66),
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
                                    color: AppTheme.textOnLightColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              currentUser?.position ?? 'Guest',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textOnLightColor
                                        .withValues(alpha: 79),
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
                      const Divider(
                          indent: AppTheme.spacingLarge,
                          endIndent: AppTheme.spacingLarge),
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
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
                  color: AppTheme.neutralColor,
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
                color: color ?? AppTheme.accentColor,
                size: 25,
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color ?? AppTheme.textOnLightColor,
                      fontWeight: FontWeight.w700,
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
        color: AppTheme.primaryColor.withValues(alpha: 160),
        boxShadow: AppTheme.neumorphicShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSmall,
            vertical: AppTheme.spacingXSmall,
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
                        BorderRadius.circular(AppTheme.borderRadiusLarge),
                    child: AnimatedContainer(
                      duration: AppTheme.animationFast,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingSmall,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? AppTheme.accentColor
                                : AppTheme.secondaryColor,
                            size: 26,
                          ),
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            item.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppTheme.accentColor
                                      : AppTheme.secondaryColor,
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
  final VoidCallback onNavigateToQuests;
  final VoidCallback onNavigateToRewards;

  const _DashboardPage({
    required this.onNavigateToQuests,
    required this.onNavigateToRewards,
  });

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
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Highlights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textOnPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Join 1,234 active members in your area!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textOnPrimaryColor.withValues(alpha: 30),
                ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onNavigateToQuests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                  ),
                  child: const Text('Join Quest'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNavigateToRewards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 26),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMedium,
                    ),
                  ),
                  child: const Text('View Community'),
                ),
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
                  ? AppTheme.primaryColor.withValues(alpha: 106)
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
                      ? AppTheme.primaryColor.withValues(alpha: 206)
                      : AppTheme.accentColor.withValues(alpha: 206),
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
                                  color: AppTheme.textOnLightColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        '${user.points} points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textOnLightColor
                                  .withValues(alpha: 79),
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
                      color: AppTheme.primaryColor.withValues(alpha: 56),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                    ),
                    child: Text(
                      'You',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
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
        color: AppTheme.successColor,
        backgroundColor: AppTheme.warningColor.withValues(alpha: 26),
      ),
      (
        icon: Icons.emoji_events_rounded,
        title: 'New Achievement',
        subtitle: 'Alex K. earned Explorer Badge',
        time: '5h ago',
        color: AppTheme.secondaryColor,
        backgroundColor: AppTheme.warningColor.withValues(alpha: 26),
      ),
      (
        icon: Icons.location_on_rounded,
        title: 'Popular Location',
        subtitle: '5 members visited Roman Forum',
        time: '1d ago',
        color: AppTheme.accentColor,
        backgroundColor: AppTheme.warningColor.withValues(alpha: 26),
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
                      color: activity.backgroundColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
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
