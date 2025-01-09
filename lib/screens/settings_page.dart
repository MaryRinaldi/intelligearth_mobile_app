import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/preferences_service.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _preferencesService = PreferencesService();
  bool _tutorialEnabled = true;
  bool _questsEnabled = true;
  bool _photosEnabled = true;
  bool _achievementsEnabled = true;
  bool _userDataEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _preferencesService.getPreferences();
      if (mounted) {
        setState(() {
          _tutorialEnabled = prefs.tutorialEnabled;
          _questsEnabled = prefs.questsEnabled;
          _photosEnabled = prefs.photosEnabled;
          _achievementsEnabled = prefs.achievementsEnabled;
          _userDataEnabled = prefs.userDataEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Errore nel caricamento delle preferenze');
      }
    }
  }

  Future<void> _updatePreferences() async {
    try {
      await _preferencesService.updatePreferences(
        tutorialEnabled: _tutorialEnabled,
        questsEnabled: _questsEnabled,
        photosEnabled: _photosEnabled,
        achievementsEnabled: _achievementsEnabled,
        userDataEnabled: _userDataEnabled,
      );
      if (!mounted) return;
      _showSnackBar('Preferenze aggiornate con successo');
    } catch (e) {
      if (!mounted) return;
      // Ripristina i valori precedenti in caso di errore
      await _loadPreferences();
      _showSnackBar('Errore nell\'aggiornamento delle preferenze');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
    );
  }

  Widget _buildPreferenceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(AppTheme.spacingXSmall),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(icon, color: Colors.grey[800]),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Impostazioni',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Container(
          color: Colors.grey[50],
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestione App',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 13),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.settings_backup_restore_rounded,
                            title: 'Gestione Dati Applicazione',
                            subtitle: 'Ripristina e gestisci i dati dell\'applicazione',
                            onTap: _showResetDialog,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Lingua',
                            subtitle: 'Cambia la lingua dell\'applicazione',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog.fullscreen(
                                  child: Scaffold(
                                    appBar: AppBar(
                                      leading: IconButton(
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      title: Text(
                                        'Lingua',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    body: SafeArea(
                                      child: Container(
                                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                                        color: Colors.grey[50],
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Seleziona la lingua dell\'applicazione:',
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: AppTheme.spacingLarge),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 13),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  _buildSettingsTile(
                                                    icon: Icons.flag_rounded,
                                                    title: 'Italiano',
                                                    subtitle: 'Imposta l\'italiano come lingua',
                                                    onTap: () {
                                                      context.read<LocaleProvider>().setLocale(const Locale('it'));
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  const Divider(height: 1, indent: 56),
                                                  _buildSettingsTile(
                                                    icon: Icons.flag_rounded,
                                                    title: 'English',
                                                    subtitle: 'Set English as language',
                                                    onTap: () {
                                                      context.read<LocaleProvider>().setLocale(const Locale('en'));
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsTile(
                            icon: Icons.notifications_rounded,
                            title: 'Notifiche',
                            subtitle: 'Gestisci le notifiche dell\'app',
                            onTap: () async {
                              final bool notificationsEnabled = await _preferencesService.getNotificationsEnabled();
                              if (!context.mounted) return;
                              
                              showDialog(
                                context: context,
                                builder: (context) => Dialog.fullscreen(
                                  child: StatefulBuilder(
                                    builder: (context, setState) => Scaffold(
                                      appBar: AppBar(
                                        leading: IconButton(
                                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        title: Text(
                                          'Gestione Notifiche',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                      body: SafeArea(
                                        child: Container(
                                          padding: const EdgeInsets.all(AppTheme.spacingLarge),
                                          color: Colors.grey[50],
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Impostazioni Notifiche',
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: AppTheme.spacingLarge),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 13),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: _buildPreferenceOption(
                                                  icon: Icons.notifications_active_rounded,
                                                  title: 'Notifiche Push',
                                                  subtitle: 'Ricevi notifiche per nuove quest e aggiornamenti',
                                                  value: notificationsEnabled,
                                                  onChanged: (bool value) async {
                                                    await _preferencesService.setNotificationsEnabled(value);
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 13),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.person_rounded,
                            title: 'Profilo',
                            subtitle: 'Gestisci il tuo profilo',
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildSettingsTile(
                            icon: Icons.security_rounded,
                            title: 'Privacy e Sicurezza',
                            subtitle: 'Gestisci le impostazioni di privacy',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog.fullscreen(
                                  child: Scaffold(
                                    appBar: AppBar(
                                      leading: IconButton(
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      title: Text(
                                        'Privacy e Sicurezza',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    body: SafeArea(
                                      child: Container(
                                        padding: const EdgeInsets.all(AppTheme.spacingLarge),
                                        color: Colors.grey[50],
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Impostazioni Privacy',
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: AppTheme.spacingLarge),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 13),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  _buildSettingsTile(
                                                    icon: Icons.location_on_rounded,
                                                    title: 'Posizione',
                                                    subtitle: 'Gestisci i permessi di localizzazione',
                                                    onTap: () async {
                                                      final bool locationEnabled = await _preferencesService.getLocationPermission();
                                                      if (!context.mounted) return;
                                                      
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => Dialog.fullscreen(
                                                          child: StatefulBuilder(
                                                            builder: (context, setState) => Scaffold(
                                                              appBar: AppBar(
                                                                leading: IconButton(
                                                                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                                                  onPressed: () => Navigator.pop(context),
                                                                ),
                                                                title: Text(
                                                                  'Permessi Posizione',
                                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.black87,
                                                                  ),
                                                                ),
                                                                backgroundColor: Colors.white,
                                                                elevation: 0,
                                                              ),
                                                              body: SafeArea(
                                                                child: Container(
                                                                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                                                                  color: Colors.grey[50],
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        'Impostazioni Posizione',
                                                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                                          color: Theme.of(context).primaryColor,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: AppTheme.spacingLarge),
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withValues(alpha: 13),
                                                                              blurRadius: 10,
                                                                              offset: const Offset(0, 2),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: _buildPreferenceOption(
                                                                          icon: Icons.location_on_rounded,
                                                                          title: 'Accesso alla posizione',
                                                                          subtitle: 'Permetti all\'app di accedere alla tua posizione',
                                                                          value: locationEnabled,
                                                                          onChanged: (bool value) async {
                                                                            await _preferencesService.setLocationPermission(value);
                                                                            setState(() {});
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const Divider(height: 1, indent: 56),
                                                  _buildSettingsTile(
                                                    icon: Icons.delete_rounded,
                                                    title: 'Elimina Dati',
                                                    subtitle: 'Elimina tutti i dati dell\'app',
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Elimina Dati'),
                                                          content: const Text('Sei sicuro di voler eliminare tutti i dati? Questa azione non può essere annullata.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: const Text('Annulla'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                await _preferencesService.resetAllData();
                                                                if (!context.mounted) return;
                                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                                              },
                                                              style: TextButton.styleFrom(
                                                                foregroundColor: Colors.red,
                                                              ),
                                                              child: const Text('Elimina'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(
          icon,
          color: Colors.grey[800],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Future<void> _showResetDialog() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: StatefulBuilder(
          builder: (context, setDialogState) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Gestione Preferenze',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    _updatePreferences();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Salva'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  color: Colors.grey[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tutorial e Onboarding',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildPreferenceOption(
                        icon: Icons.refresh_rounded,
                        title: 'Tutorial Iniziale',
                        subtitle: 'Attiva/disattiva il tutorial e le schermate di introduzione',
                        value: _tutorialEnabled,
                        onChanged: (value) {
                          setDialogState(() {
                            _tutorialEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text(
                        'Dati e Progressi',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildPreferenceOption(
                        icon: Icons.explore_rounded,
                        title: 'Quest e Progressi',
                        subtitle: 'Attiva/disattiva le quest completate e i progressi',
                        value: _questsEnabled,
                        onChanged: (value) {
                          setDialogState(() {
                            _questsEnabled = value;
                          });
                        },
                      ),
                      _buildPreferenceOption(
                        icon: Icons.emoji_events_rounded,
                        title: 'Achievements e Punti',
                        subtitle: 'Attiva/disattiva gli achievements e il punteggio',
                        value: _achievementsEnabled,
                        onChanged: (value) {
                          setDialogState(() {
                            _achievementsEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text(
                        'Media e Privacy',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildPreferenceOption(
                        icon: Icons.photo_library_rounded,
                        title: 'Foto e Media',
                        subtitle: 'Attiva/disattiva l\'accesso alle foto caricate',
                        value: _photosEnabled,
                        onChanged: (value) {
                          setDialogState(() {
                            _photosEnabled = value;
                          });
                        },
                      ),
                      _buildPreferenceOption(
                        icon: Icons.person_rounded,
                        title: 'Dati Utente',
                        subtitle: 'Attiva/disattiva le preferenze utente e la cronologia',
                        value: _userDataEnabled,
                        onChanged: (value) {
                          setDialogState(() {
                            _userDataEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
