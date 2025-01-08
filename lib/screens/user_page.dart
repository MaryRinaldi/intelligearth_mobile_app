import 'package:flutter/material.dart';
import 'package:intelligearth_mobile/models/user_model.dart';
import '../theme/app_theme.dart';

class UserPage extends StatelessWidget {
  final User user;

  const UserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.id.isEmpty) {
      return const Center(
        child: Text(
          'Utente non trovato. Per favore effettua il login.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        _buildProfileHeader(context),
        const SizedBox(height: AppTheme.spacingLarge),
        _buildAchievements(context),
        const SizedBox(height: AppTheme.spacingLarge),
        _buildPersonalStats(context),
        const SizedBox(height: AppTheme.spacingLarge),
        _buildCompletedQuests(context),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty
                  ? user.name.substring(0, 1).toUpperCase()
                  : 'Mary',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textOnPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textOnPrimaryColor.withValues(alpha: 130),
                ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.textOnPrimaryColor.withValues(alpha: 26),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Text(
              'Level 15 Explorer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final achievements = [
      (
        icon: Icons.eco_rounded,
        title: 'Nature Guardian',
        description: 'Planted 10 trees',
        progress: 0.8,
        color: AppTheme.successColor
      ),
      (
        icon: Icons.camera_alt_rounded,
        title: 'Photo Master',
        description: 'Shared 50 photos',
        progress: 0.6,
        color: AppTheme.accentColor
      ),
      (
        icon: Icons.location_on_rounded,
        title: 'Explorer',
        description: 'Visited 20 locations',
        progress: 1.0,
        color: AppTheme.warningColor
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        ...achievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
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
                    color: achievement.color.withValues(alpha: 106),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        achievement.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.neutralColor,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusLarge),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor:
                              achievement.color.withValues(alpha: 26),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(achievement.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPersonalStats(BuildContext context) {
    final stats = [
      (
        icon: Icons.emoji_events_rounded,
        label: 'Total Points',
        value: '2,450',
        trend: '+150 this week'
      ),
      (
        icon: Icons.check_circle_rounded,
        label: 'Quests Completed',
        value: '48',
        trend: '+3 this week'
      ),
      (
        icon: Icons.trending_up_rounded,
        label: 'Current Streak',
        value: '7 days',
        trend: 'Best: 15 days'
      ),
      (
        icon: Icons.favorite_rounded,
        label: 'Reputation',
        value: '4.8/5.0',
        trend: '125 ratings'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingMedium,
          crossAxisSpacing: AppTheme.spacingMedium,
          children: stats.map((stat) {
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
                    color: AppTheme.accentColor,
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
        ),
      ],
    );
  }

  Widget _buildCompletedQuests(BuildContext context) {
    final quests = [
      (
        title: 'Colosseum Quest',
        date: '2 days ago',
        points: '+150',
        imagePath: 'assets/images/3D_Colosseum_quest.png'
      ),
      (
        title: 'Roman Forum',
        date: '1 week ago',
        points: '+120',
        imagePath: 'assets/images/roman_forum.png'
      ),
      (
        title: 'Pantheon',
        date: '2 weeks ago',
        points: '+100',
        imagePath: 'assets/images/roman_pantheon.png'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Quests',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        ...quests.map((quest) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: Image.asset(
                    quest.imagePath,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Row(
                    children: [
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
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              'Completed ${quest.date}',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSmall,
                          vertical: AppTheme.spacingXSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 106),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                        ),
                        child: Text(
                          quest.points,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
