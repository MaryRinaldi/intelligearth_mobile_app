import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/quest_model.dart';
import '../screens/map_screen.dart';
import '../screens/quest_detail_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  Position? _userPosition;
  bool _isLocationPermissionChecked = false;

  final List<Quest> quests = [
    Quest(
      title: 'Quest del Colosseo',
      imagePath: 'assets/images/3D_Colosseum_quest.png',
      latitude: 41.8902,
      longitude: 12.4922,
      description: 'Esplora il magnifico Colosseo e scopri i suoi segreti',
      progress: 0.3,
    ),
    Quest(
      title: 'Quest della Torre di Pisa',
      imagePath: 'assets/images/3D_PisaTower_quest.png',
      latitude: 43.7229,
      longitude: 10.3966,
      description: 'Visita la famosa Torre pendente di Pisa',
      progress: 0.7,
      status: QuestStatus.active,
    ),
    Quest(
      title: 'Quest del Pantheon',
      imagePath: 'assets/images/roman_pantheon.png',
      latitude: 41.8986,
      longitude: 12.4768,
      description:
          'Scopri la maestosità del Pantheon romano nella suggestiva Piazza della Rotonda',
      progress: 1.0,
      status: QuestStatus.completed,
    ),
    Quest(
      title: 'Quest del Roman Forum',
      imagePath: 'assets/images/roman_forum.png',
      latitude: 41.8924,
      longitude: 12.4853,
      description:
          'Esplora le antiche rovine del Foro Romano, cuore dell\'antica Roma',
      progress: 1.0,
      status: QuestStatus.completed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      });
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (_isLocationPermissionChecked) return;

    final prefs = await SharedPreferences.getInstance();
    final hasLocationPermission = prefs.getBool('location_permission') ?? false;

    if (hasLocationPermission) {
      _startLocationUpdates();
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    await prefs.setBool('location_permission', true);
    _startLocationUpdates();
    setState(() => _isLocationPermissionChecked = true);
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() => _userPosition = position);
    });
  }

  List<Quest> _getSortedQuests(List<Quest> questList) {
    if (_userPosition == null) return questList;

    return List<Quest>.from(questList)
      ..sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 255, 255, 255),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.secondaryColor,
                unselectedLabelColor:
                    const Color.fromRGBO(57, 67, 122, 1).withValues(alpha: 19),
                indicatorColor: const Color.fromARGB(105, 255, 255, 255),
                tabAlignment: TabAlignment.fill,
                isScrollable: false,
                tabs: [
                  SizedBox(
                    height: 56,
                    child:
                        _buildTab(AppLocalizations.of(context)!.activeQuests, 0),
                  ),
                  SizedBox(
                    height: 56,
                    child: _buildTab(
                        AppLocalizations.of(context)!.completedQuests, 1),
                  ),
                  const SizedBox(
                    height: 56,
                    child: Tab(icon: Icon(Icons.map_rounded)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _QuestList(
                    status: QuestStatus.active,
                    quests: _getSortedQuests(quests),
                  ),
                  _QuestList(
                    status: QuestStatus.completed,
                    quests: _getSortedQuests(quests),
                  ),
                  MapScreen(
                    latitude: _userPosition?.latitude ?? 41.8902,
                    longitude: _userPosition?.longitude ?? 12.4922,
                    title: 'Mappa delle Quest',
                    showBackButton: false,
                    markers: quests
                        .map((quest) => QuestMarker(
                              latitude: quest.latitude,
                              longitude: quest.longitude,
                              title: quest.title,
                              isCompleted: quest.status == QuestStatus.completed,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Tab(
      child: AnimatedDefaultTextStyle(
        duration: AppTheme.animationFast,
        style: TextStyle(
          fontSize: isSelected ? 20 : 17,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.neutralColor.withValues(alpha: 68),
        ),
        child: Text(text),
      ),
    );
  }
}

class _QuestList extends StatelessWidget {
  const _QuestList({
    required this.status,
    required this.quests,
  });

  final QuestStatus status;
  final List<Quest> quests;

  @override
  Widget build(BuildContext context) {
    final filteredQuests = quests.where((q) => q.status == status).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemCount: filteredQuests.length,
      itemBuilder: (context, index) {
        final quest = filteredQuests[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _QuestCard(quest: quest),
        );
      },
    );
  }
}

class _QuestCard extends StatefulWidget {
  const _QuestCard({
    required this.quest,
  });

  final Quest quest;

  @override
  State<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<_QuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onQuestTap(BuildContext context, Quest quest) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestDetailScreen(quest: quest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            _onQuestTap(context, widget.quest);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 230),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: _isPressed ? [] : AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestImage(),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.quest.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textOnLightColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        widget.quest.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textOnLightColor
                                  .withValues(alpha: 179),
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppTheme.textOnLightColor
                                      .withValues(alpha: 179),
                                ),
                          ),
                          Text(
                            '${(widget.quest.progress * 100).toInt()}%',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestImage() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
        image: DecorationImage(
          image: AssetImage(widget.quest.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = {
      QuestStatus.active: (color: AppTheme.accentColor, label: 'Active'),
      QuestStatus.completed: (color: AppTheme.successColor, label: 'Completed'),
      QuestStatus.upcoming: (color: AppTheme.warningColor, label: 'Upcoming'),
    };

    final config = statusConfig[widget.quest.status]!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 206),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Text(
        config.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
