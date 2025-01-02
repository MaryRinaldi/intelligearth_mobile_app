import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _resetPreferences(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');
    await prefs.remove('tutorial_seen');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tutorial ripristinato'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _resetCommunityData(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Dati Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scegli cosa ripristinare:'),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading:
                  Icon(Icons.explore_rounded, color: AppTheme.warningColor),
              title: Text('Quest Completate'),
              subtitle: Text('Azzera i progressi delle quest'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('quests_progress');
                await prefs.remove('completed_quests');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Quest ripristinate')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: AppTheme.warningColor),
              title: Text('Foto Caricate'),
              subtitle: Text('Elimina tutte le foto caricate'),
              onTap: () async {
                final dir = await getApplicationDocumentsDirectory();
                final photoDir = Directory('${dir.path}/photos');
                if (await photoDir.exists()) {
                  await photoDir.delete(recursive: true);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Foto eliminate')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_events_rounded,
                  color: AppTheme.warningColor),
              title: Text('Achievements e Punti'),
              subtitle: Text('Azzera achievements e punteggio'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('achievements');
                await prefs.remove('points');
                await prefs.remove('badges');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Achievements e punti azzerati')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUserData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_preferences');
    await prefs.remove('exploration_history');
    await prefs.remove('visited_locations');
    await prefs.remove('user_stats');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dati utente ripristinati'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ripristina Applicazione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scegli cosa ripristinare:'),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading:
                  Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
              title: Text('Tutorial Iniziale'),
              subtitle: Text('Rivedi le schermate di introduzione'),
              onTap: () {
                Navigator.pop(context);
                _resetPreferences(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.group_rounded, color: AppTheme.warningColor),
              title: Text('Dati Community'),
              subtitle: Text('Gestisci quest, foto e achievements'),
              onTap: () {
                Navigator.pop(context);
                _resetCommunityData(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_rounded, color: AppTheme.warningColor),
              title: Text('Dati Utente'),
              subtitle: Text('Reimposta preferenze utente e cronologia'),
              onTap: () {
                Navigator.pop(context);
                _resetUserData(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: Text('Disconnetti'),
              subtitle: Text('Esci dall\'account'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        ListTile(
          leading:
              Icon(Icons.restart_alt_rounded, color: AppTheme.primaryColor),
          title: Text('Ripristina Applicazione'),
          subtitle: Text('Gestisci dati e preferenze dell\'applicazione'),
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }
}
