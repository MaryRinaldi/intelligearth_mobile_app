import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _resetPreferences(BuildContext context) async {
    final preferencesService = PreferencesService();
    await preferencesService.resetTutorialAndOnboarding();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tutorial ripristinato'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _resetCommunityData(BuildContext context) async {
    final preferencesService = PreferencesService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Dati Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scegli cosa ripristinare:'),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading:
                  Icon(Icons.explore_rounded, color: AppTheme.warningColor),
              title: const Text('Quest Completate'),
              subtitle: const Text('Azzera i progressi delle quest'),
              onTap: () async {
                await preferencesService.resetCommunityData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quest ripristinate')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: AppTheme.warningColor),
              title: const Text('Foto Caricate'),
              subtitle: const Text('Elimina tutte le foto caricate'),
              onTap: () async {
                final dir = await getApplicationDocumentsDirectory();
                final photoDir = Directory('${dir.path}/photos');
                if (await photoDir.exists()) {
                  await photoDir.delete(recursive: true);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto eliminate')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_events_rounded,
                  color: AppTheme.warningColor),
              title: const Text('Achievements e Punti'),
              subtitle: const Text('Azzera achievements e punteggio'),
              onTap: () async {
                await preferencesService.resetCommunityData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Achievements e punti azzerati')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUserData(BuildContext context) async {
    final preferencesService = PreferencesService();
    await preferencesService.resetUserData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dati utente ripristinati'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ripristina Applicazione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scegli cosa ripristinare:'),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading:
                  Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
              title: const Text('Tutorial Iniziale'),
              subtitle: const Text('Rivedi le schermate di introduzione'),
              onTap: () {
                Navigator.pop(context);
                _resetPreferences(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.group_rounded, color: AppTheme.warningColor),
              title: const Text('Dati Community'),
              subtitle: const Text('Gestisci quest, foto e achievements'),
              onTap: () {
                Navigator.pop(context);
                _resetCommunityData(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_rounded, color: AppTheme.warningColor),
              title: const Text('Dati Utente'),
              subtitle: const Text('Reimposta preferenze utente e cronologia'),
              onTap: () {
                Navigator.pop(context);
                _resetUserData(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: const Text('Disconnetti'),
              subtitle: const Text('Esci dall\'account'),
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
            child: const Text('Annulla'),
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
          title: const Text('Ripristina Applicazione'),
          subtitle: const Text('Gestisci dati e preferenze dell\'applicazione'),
          onTap: () => _showResetDialog(context),
        ),
      ],
    );
  }
}
