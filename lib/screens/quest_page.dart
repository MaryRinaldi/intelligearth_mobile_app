import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/quest_model.dart';
import '../screens/map_screen.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

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
    // Altre quest...
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildAppBar(l10n),
            _buildTabBar(l10n),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _QuestList(status: QuestStatus.active, quests: quests),
              _QuestList(status: QuestStatus.completed, quests: quests),
              _QuestList(status: QuestStatus.upcoming, quests: quests),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Implementa la funzionalità per aggiungere nuove quest
          },
          backgroundColor: AppTheme.accentColor,
          child: const Icon(Icons.add, color: AppTheme.lightColor),
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 130,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(253, 253, 253, 0.1),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.questPageTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppTheme.lightColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        l10n.questPageSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color.fromRGBO(253, 253, 253, 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: const Color.fromRGBO(39, 47, 64, 0.5),
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(text: l10n.activeQuests),
            Tab(text: l10n.completedQuests),
            Tab(text: l10n.upcomingQuests),
          ],
        ),
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
      itemBuilder: (context, index) => _QuestCard(
        quest: filteredQuests[index],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
  });

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'quest_${quest.title}',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          side: BorderSide(
            color: const Color.fromRGBO(48, 90, 114, 0.1),
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(
                  latitude: quest.latitude,
                  longitude: quest.longitude,
                  questTitle: quest.title,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildQuestImage(),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingXSmall),
                          Text(
                            quest.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: const Color.fromRGBO(39, 47, 64, 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/icons/go-to.png',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
                if (quest.status == QuestStatus.active) ...[
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Image.asset(
          quest.imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progress'),
            Text('${(quest.progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        LinearProgressIndicator(
          value: quest.progress,
          backgroundColor: const Color.fromRGBO(48, 90, 114, 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.lightColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
