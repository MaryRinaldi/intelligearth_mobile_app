import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/preferences_service.dart';
import '../screens/settings/notifications_settings_page.dart';
import '../providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool _promotionalNotifications = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'it';
  bool _highContrastMode = false;
  double _textSize = 16.0; // Default text size
  String _themeMode = 'system'; // Aggiungiamo questa variabile
  bool _systemNotifications = true;
  bool _questNotifications = true;
  bool _messageNotifications = true;
  bool _dataConsent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    try {
      // Carica tutte le preferenze in parallelo
      final results = await Future.wait([
        _preferencesService.getPreferences(),
        _preferencesService.getNotificationsEnabled(),
        _preferencesService.getSystemNotifications(),
        _preferencesService.getQuestNotifications(),
        _preferencesService.getMessageNotifications(),
        _preferencesService.getHighContrastMode(),
        _preferencesService.getTextSize(),
        _preferencesService.getThemeMode(),
      ]);
      
      if (mounted) {
        setState(() {
          final prefs = results[0] as PreferencesData;
          _tutorialEnabled = prefs.tutorialEnabled;
          _questsEnabled = prefs.questsEnabled;
          _photosEnabled = prefs.photosEnabled;
          _achievementsEnabled = prefs.achievementsEnabled;
          _userDataEnabled = prefs.userDataEnabled;
          _promotionalNotifications = prefs.promotionalNotifications;
          _selectedLanguage = prefs.language;
          _dataConsent = prefs.dataConsent;
          
          _notificationsEnabled = results[1] as bool;
          _systemNotifications = results[2] as bool;
          _questNotifications = results[3] as bool;
          _messageNotifications = results[4] as bool;
          _highContrastMode = results[5] as bool;
          _textSize = results[6] as double;
          _themeMode = results[7] as String;
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
        themeMode: _themeMode,
        promotionalNotifications: _promotionalNotifications,
        language: _selectedLanguage,
      );

      // Aggiorniamo anche le altre preferenze specifiche
      await Future.wait([
        _preferencesService.setHighContrastMode(_highContrastMode),
        _preferencesService.setTextSize(_textSize),
        _preferencesService.setNotificationsEnabled(_notificationsEnabled),
        _preferencesService.setSystemNotifications(_systemNotifications),
        _preferencesService.setQuestNotifications(_questNotifications),
        _preferencesService.setMessageNotifications(_messageNotifications),
        _preferencesService.setDataConsent(_dataConsent),
      ]);
      
      if (!mounted) return;
      _showSnackBar('Preferenze aggiornate con successo');
    } catch (e) {
      if (!mounted) return;
      await _loadPreferences(); // Ricarica le preferenze in caso di errore
      _showSnackBar('Errore nell\'aggiornamento delle preferenze');
    }
  }

  Future<void> _updateThemeMode(String mode) async {
    try {
      await _preferencesService.setThemeMode(mode);
      setState(() {
        _themeMode = mode;
      });
      
      if (!mounted) return;
      _showSnackBar('Tema aggiornato con successo');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Errore nell\'aggiornamento del tema');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Rimuove eventuali snackbar precedenti
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
    String? description,
    bool requiresConfirmation = false,
  }) {
    Future<void> handleChange(bool newValue) async {
      try {
        if (requiresConfirmation) {
          _showConfirmationDialog(
            'Conferma Modifica',
            'Vuoi modificare questa impostazione?',
            () async {
              await _updatePreferenceValue(title, newValue);
            },
          );
        } else {
          await _updatePreferenceValue(title, newValue);
        }
      } catch (e) {
        if (!mounted) return;
        _showSnackBar('Errore nell\'aggiornamento dell\'impostazione');
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppTheme.settingsItemVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.settingsContainerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: title,
            hint: subtitle,
            value: value ? 'attivato' : 'disattivato',
            child: SwitchListTile(
              value: value,
              onChanged: handleChange,
              activeColor: Colors.white,
              activeTrackColor: AppTheme.successColor.withValues(alpha: 179),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppTheme.errorColor.withValues(alpha: 179),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.settingsItemHorizontalPadding,
                vertical: AppTheme.settingsItemVerticalPadding,
              ),
              secondary: Container(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey[600],
                  size: AppTheme.settingsIconSize,
                ),
              ),
              title: Text(title, style: AppTheme.settingsTitleStyle),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.settingsSubtitleStyle),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(description, style: AppTheme.settingsDescriptionStyle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePreferenceValue(String preferenceName, bool value) async {
    switch (preferenceName) {
      case 'Guide Automatiche':
        setState(() => _tutorialEnabled = value);
        await _preferencesService.setTutorialEnabled(value);
        break;
      case 'Salvataggio Progressi':
        setState(() => _questsEnabled = value);
        await _preferencesService.setQuestsEnabled(value);
        break;
      case 'Modalità Alto Contrasto':
        setState(() => _highContrastMode = value);
        await _preferencesService.setHighContrastMode(value);
        break;
      case 'Consenso al Trattamento':
        if (!value) {
          _showConsentRevocationDialog();
        } else {
          setState(() => _dataConsent = value);
          await _preferencesService.setDataConsent(value);
        }
        break;
      // Aggiungi altri casi per le altre preferenze
      default:
        throw Exception('Preferenza non gestita: $preferenceName');
    }
    await _updatePreferences(); // Aggiorna tutte le preferenze
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: Semantics(
              label: 'Torna indietro',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
        ],
        body:ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                child: _buildSettingsSection(context),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader(AppLocalizations.of(context)!.account),
              _buildActionTile(
                icon: Icons.logout_rounded,
                title: AppLocalizations.of(context)!.logoutTitle,
                subtitle: AppLocalizations.of(context)!.logoutSubtitle,
                onTap: () => _showLogoutDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.person_off_rounded,
                title: 'Dimentica Account',
                subtitle: 'Disattiva "Ricordami" e cancella i dati di accesso salvati',
                onTap: () => _showForgetAccountDialog(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Sezione Aspetto e Accessibilità
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Aspetto e Accessibilità'),
              _buildThemeSection(),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildLanguageSelector(),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Sezione Notifiche
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Notifiche'),
              _buildNotificationsSection(),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Sezione Tutorial e Guide
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Tutorial e Guide'),
              _buildActionTile(
                icon: Icons.replay_rounded,
                title: 'Rivedi Tutorial',
                subtitle: 'Visualizza nuovamente il tutorial iniziale',
                onTap: () => _showReviewTutorialDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildPreferenceOption(
                icon: Icons.help_outline_rounded,
                title: 'Guide Automatiche',
                subtitle: 'Mostra suggerimenti durante l\'utilizzo',
                value: _tutorialEnabled,
                onChanged: (value) {
                  setState(() => _tutorialEnabled = value);
                  _updatePreferences();
                },
                description: 'Attiva o disattiva i suggerimenti automatici durante l\'uso dell\'app',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Sezione Privacy e Dati
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Privacy e Dati'),
              _buildPreferenceOption(
                icon: Icons.save_rounded,
                title: 'Salvataggio Progressi',
                subtitle: 'Mantieni i progressi delle quest e delle sfide',
                value: _questsEnabled,
                onChanged: (value) => _showConfirmationDialog(
                  'Conferma Modifica',
                  value 
                    ? 'Vuoi attivare il salvataggio dei progressi?'
                    : 'Disattivando questa opzione, i progressi non salvati andranno persi. Continuare?',
                  () {
                    setState(() => _questsEnabled = value);
                    _updatePreferences();
                  },
                ),
                description: 'Gestisce il salvataggio dei progressi nelle missioni',
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.cloud_upload_rounded,
                title: 'Backup e Sincronizzazione',
                subtitle: 'Sincronizza le preferenze con il cloud',
                onTap: () => _showBackupDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.restore_rounded,
                title: 'Ripristina Preferenze',
                subtitle: 'Reimposta tutte le preferenze ai valori predefiniti',
                onTap: () => _showResetPreferencesDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.delete_rounded,
                title: 'Cancella Tutti i Dati',
                subtitle: 'Elimina tutte le preferenze e i dati salvati',
                isDestructive: true,
                onTap: () => _showDeleteDataDialog(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Nuova sezione Accessibilità
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Accessibilità'),
              _buildPreferenceOption(
                icon: Icons.contrast_rounded,
                title: 'Modalità Alto Contrasto',
                subtitle: 'Aumenta il contrasto dei colori',
                value: _highContrastMode,
                onChanged: (value) async {
                  setState(() => _highContrastMode = value);
                  await _preferencesService.setHighContrastMode(value);
                },
                description: 'Migliora la leggibilità aumentando il contrasto tra testo e sfondo',
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: Icon(
                            Icons.format_size_rounded,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dimensione Testo',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Regola la dimensione del testo',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Slider(
                      value: _textSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 6,
                      label: '${_textSize.round()}',
                      onChanged: (value) async {
                        setState(() => _textSize = value);
                        await _preferencesService.setTextSize(value);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('A', style: TextStyle(fontSize: 12)),
                          Text('A', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Nuova sezione Guida e Supporto
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Guida e Supporto'),
              _buildActionTile(
                icon: Icons.help_outline_rounded,
                title: 'Guida Rapida',
                subtitle: 'Istruzioni per l\'uso delle impostazioni',
                onTap: () => _showGuideDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.support_rounded,
                title: 'Supporto',
                subtitle: 'Contatta l\'assistenza',
                onTap: () => _showSupportDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.restore_rounded,
                title: 'Ripristina Impostazioni',
                subtitle: 'Reimposta tutte le preferenze ai valori predefiniti',
                onTap: () => _showResetDialog(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLarge),

        // Nuova sezione Privacy e GDPR
        Container(
          decoration: _buildContainerDecoration(),
          child: Column(
            children: [
              _buildSectionHeader('Privacy e GDPR'),
              _buildPreferenceOption(
                icon: Icons.verified_user_rounded,
                title: 'Consenso al Trattamento',
                subtitle: 'Gestisci il consenso per l\'utilizzo dei dati',
                value: _dataConsent,
                onChanged: (value) async {
                  if (!value) {
                    _showConsentRevocationDialog();
                  } else {
                    setState(() => _dataConsent = value);
                    await _preferencesService.setDataConsent(value);
                  }
                },
                description: 'Autorizza l\'app a raccogliere e utilizzare i tuoi dati personali',
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.download_rounded,
                title: 'Esporta Dati Personali',
                subtitle: 'Scarica una copia dei tuoi dati',
                onTap: () => _showExportDataDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.delete_forever_rounded,
                title: 'Elimina Account e Dati',
                subtitle: 'Rimuovi definitivamente il tuo account e tutti i dati associati',
                isDestructive: true,
                onTap: () => _showDeleteAccountDialog(),
              ),
              const Divider(
                height: 1,
                indent: AppTheme.settingsDividerIndent,
              ),
              _buildActionTile(
                icon: Icons.policy_rounded,
                title: 'Informativa Privacy',
                subtitle: 'Leggi come utilizziamo i tuoi dati',
                onTap: () => _showPrivacyPolicyDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: Colors.grey[600],
            ),
          ),
          title: const Text('Tema dell\'app'),
          trailing: DropdownButton<String>(
            value: _themeMode,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _updateThemeMode(newValue);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'light',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.light_mode_rounded, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Text('Chiaro'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'dark',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dark_mode_rounded, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Text('Scuro'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          indent: AppTheme.settingsDividerIndent,
        ),
        _buildPreferenceOption(
          icon: Icons.contrast_rounded,
          title: 'Modalità Alto Contrasto',
          subtitle: 'Aumenta il contrasto dei colori',
          value: _highContrastMode,
          onChanged: (value) async {
            setState(() => _highContrastMode = value);
            await _preferencesService.setHighContrastMode(value);
          },
          description: 'Migliora la leggibilità aumentando il contrasto tra testo e sfondo',
        ),
      ],
    );
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  void _showForgetAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dimentica Account'),
        content: const Text(
          'Questa azione disattiverà il login automatico e cancellerà i dati di accesso salvati. '
          'Dovrai effettuare nuovamente l\'accesso al prossimo utilizzo dell\'app.\n\n'
          'Vuoi continuare?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _preferencesService.setRememberMe(false);
              await _preferencesService.clearStoredUser();
              if (!mounted) return;
              _showSnackBar('Dati di accesso rimossi con successo');
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  void _showReviewTutorialDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rivedi Tutorial'),
        content: const Text(
          'Vuoi rivedere il tutorial iniziale?\n\n'
          'Verrai reindirizzato alla schermata di benvenuto e potrai vedere nuovamente tutte le guide.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _preferencesService.resetTutorialAndOnboarding();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/welcome', 
                (route) => false
              );
            },
            child: const Text('Rivedi Tutorial'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.settingsItemHorizontalPadding,
        vertical: AppTheme.settingsItemVerticalPadding,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey[800],
          size: AppTheme.settingsIconSize,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.settingsTitleStyle.copyWith(
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(subtitle, style: AppTheme.settingsSubtitleStyle),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    // Implementa la logica per disconnettere l'account
  }

  void _showDeleteDataDialog() {
    // Implementa la logica per cancellare tutti i dati
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.settingsItemHorizontalPadding,
        vertical: AppTheme.settingsItemVerticalPadding,
      ),
      child: Text(title, style: AppTheme.sectionHeaderStyle),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.settingsContainerRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 13),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.settingsItemHorizontalPadding,
            vertical: AppTheme.settingsItemVerticalPadding,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              Icons.language_rounded,
              color: Colors.grey[600],
              size: AppTheme.settingsIconSize,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: AppTheme.settingsTitleStyle,
          ),
          subtitle: Text(
            localeProvider.getLanguageName(localeProvider.locale.languageCode),
            style: AppTheme.settingsSubtitleStyle,
          ),
          trailing: DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            onChanged: (String? newValue) {
              if (newValue != null) {
                localeProvider.setLocale(newValue);
              }
            },
            items: LocaleProvider.supportedLocales.map((locale) {
              return DropdownMenuItem(
                value: locale.languageCode,
                child: Text(localeProvider.getLanguageName(locale.languageCode)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Backup e Sincronizzazione'),
        content: const Text(
          'Vuoi eseguire il backup delle tue preferenze?\n\n'
          'Questa operazione salverà tutte le tue impostazioni nel cloud.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _preferencesService.backupPreferences();
                if (!mounted) return;
                _showSnackBar('Backup completato con successo');
              } catch (e) {
                if (!mounted) return;
                _showSnackBar('Errore durante il backup: ${e.toString()}');
              }
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showResetPreferencesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ripristina Preferenze'),
        content: const Text(
          'Vuoi ripristinare tutte le preferenze ai valori predefiniti?\n\n'
          'Questa azione non può essere annullata.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _preferencesService.resetAllData();
                await _loadPreferences(); // Ricarica le preferenze dopo il reset
                if (!mounted) return;
                _showSnackBar('Preferenze ripristinate con successo');
              } catch (e) {
                if (!mounted) return;
                _showSnackBar('Errore durante il ripristino: ${e.toString()}');
              }
            },
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );
  }

  void _showGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Guida Rapida'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideSection(
                'Tema e Aspetto',
                'Personalizza il tema dell\'app e le impostazioni di visualizzazione.',
                [
                  'Scegli tra tema chiaro e scuro',
                  'Attiva la modalità alto contrasto per una migliore leggibilità',
                  'Regola la dimensione del testo',
                ],
              ),
              const Divider(),
              _buildGuideSection(
                'Notifiche',
                'Gestisci le preferenze per le notifiche.',
                [
                  'Attiva/disattiva le notifiche generali',
                  'Gestisci le notifiche promozionali',
                  'Personalizza gli avvisi importanti',
                ],
              ),
              const Divider(),
              _buildGuideSection(
                'Privacy e Dati',
                'Controlla come vengono gestiti i tuoi dati.',
                [
                  'Gestisci il salvataggio dei progressi',
                  'Esegui backup dei dati',
                  'Ripristina le impostazioni predefinite',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String description, List<String> points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(description),
          const SizedBox(height: AppTheme.spacingSmall),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.primaryColor)),
                Expanded(child: Text(point)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.warningColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Ripristina Impostazioni'),
          ],
        ),
        content: const Text(
          'Questa azione ripristinerà tutte le impostazioni ai valori predefiniti. '
          'Le tue preferenze attuali andranno perse.\n\n'
          'Vuoi continuare?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllPreferences();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllPreferences() async {
    try {
      await _preferencesService.resetAllData();
      await _loadPreferences(); // Ricarica le preferenze
      if (!mounted) return;
      _showSnackBar('Impostazioni ripristinate con successo');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Errore durante il ripristino delle impostazioni');
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.support_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Supporto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hai bisogno di aiuto?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildSupportOption(
              Icons.email_rounded,
              'Invia una email',
              'support@intelligearth.com',
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildSupportOption(
              Icons.phone_rounded,
              'Chiama il supporto',
              '+39 XXX XXX XXXX',
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildSupportOption(
              Icons.chat_rounded,
              'Chat dal vivo',
              'Disponibile 9:00 - 18:00',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingXSmall),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha : 20),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildActionTile(
      icon: Icons.notifications_rounded,
      title: 'Notifiche',
      subtitle: 'Gestisci tutte le notifiche',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationsSettingsPage(
              notificationsEnabled: _notificationsEnabled,
              systemNotifications: _systemNotifications,
              questNotifications: _questNotifications,
              messageNotifications: _messageNotifications,
              promotionalNotifications: _promotionalNotifications,
            ),
          ),
        );
      },
    );
  }

  void _showConsentRevocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.warningColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Revoca Consenso'),
          ],
        ),
        content: const Text(
          'Revocando il consenso al trattamento dei dati:\n\n'
          '• Non potrai più utilizzare alcune funzionalità dell\'app\n'
          '• I tuoi dati non verranno più raccolti o elaborati\n'
          '• I dati esistenti verranno conservati per obblighi legali\n\n'
          'Vuoi procedere con la revoca del consenso?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _revokeConsent();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Revoca Consenso'),
          ),
        ],
      ),
    );
  }

  Future<void> _revokeConsent() async {
    try {
      setState(() => _dataConsent = false);
      await _preferencesService.setDataConsent(false);
      await _preferencesService.disableDataCollection();
      if (!mounted) return;
      _showSnackBar('Consenso revocato con successo');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Errore durante la revoca del consenso');
    }
  }

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Esporta Dati'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scegli il formato di esportazione:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildExportOption(
              'JSON',
              'Formato leggibile da computer',
              () => _exportData('json'),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildExportOption(
              'PDF',
              'Formato leggibile da umani',
              () => _exportData('pdf'),
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

  Widget _buildExportOption(String format, String description, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXSmall),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 26),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                format == 'JSON' ? Icons.code_rounded : Icons.description_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    try {
      final success = await _preferencesService.exportUserData(format);
      if (!mounted) return;
      if (success) {
        _showSnackBar('Dati esportati con successo');
      } else {
        _showSnackBar('Errore durante l\'esportazione dei dati');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Errore durante l\'esportazione dei dati');
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Elimina Account'),
          ],
        ),
        content: const Text(
          'Questa azione è irreversibile. Il tuo account e tutti i dati associati '
          'verranno eliminati definitivamente.\n\n'
          'Vuoi procedere con l\'eliminazione?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final success = await _preferencesService.deleteUserAccount();
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        _showSnackBar('Errore durante l\'eliminazione dell\'account');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Errore durante l\'eliminazione dell\'account');
    }
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.policy_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('Informativa Privacy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrivacySection(
                'Dati Raccolti',
                'Raccogliamo e trattiamo i seguenti dati personali:',
                [
                  'Dati di registrazione (email, nome)',
                  'Dati di utilizzo dell\'app',
                  'Preferenze e impostazioni',
                  'Dati di geolocalizzazione',
                ],
              ),
              const Divider(),
              _buildPrivacySection(
                'Finalità del Trattamento',
                'I tuoi dati vengono utilizzati per:',
                [
                  'Fornirti i servizi dell\'app',
                  'Migliorare l\'esperienza utente',
                  'Inviare notifiche pertinenti',
                  'Analisi statistiche aggregate',
                ],
              ),
              const Divider(),
              _buildPrivacySection(
                'I Tuoi Diritti',
                'Hai il diritto di:',
                [
                  'Accedere ai tuoi dati',
                  'Richiedere la rettifica',
                  'Revocare il consenso',
                  'Richiedere la cancellazione',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String description, List<String> points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(description),
          const SizedBox(height: AppTheme.spacingSmall),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spacingMedium,
              bottom: AppTheme.spacingXSmall,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppTheme.primaryColor)),
                Expanded(child: Text(point)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
