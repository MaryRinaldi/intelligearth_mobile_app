import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/preferences_service.dart';

class NotificationsSettingsPage extends StatefulWidget {
  final bool notificationsEnabled;
  final bool systemNotifications;
  final bool questNotifications;
  final bool messageNotifications;
  final bool promotionalNotifications;

  const NotificationsSettingsPage({
    super.key,
    required this.notificationsEnabled,
    required this.systemNotifications,
    required this.questNotifications,
    required this.messageNotifications,
    required this.promotionalNotifications,
  });

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final PreferencesService _preferencesService = PreferencesService();
  late bool _notificationsEnabled;
  late bool _systemNotifications;
  late bool _questNotifications;
  late bool _messageNotifications;
  late bool _promotionalNotifications;
  bool _doNotDisturbEnabled = false;
  TimeOfDay? _doNotDisturbStart;
  TimeOfDay? _doNotDisturbEnd;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
    _systemNotifications = widget.systemNotifications;
    _questNotifications = widget.questNotifications;
    _messageNotifications = widget.messageNotifications;
    _promotionalNotifications = widget.promotionalNotifications;
    _loadDoNotDisturb();
  }

  Future<void> _loadDoNotDisturb() async {
    final dndEnabled = await _preferencesService.getDoNotDisturbEnabled();
    final dndStart = await _preferencesService.getDoNotDisturbStart();
    final dndEnd = await _preferencesService.getDoNotDisturbEnd();
    
    if (mounted) {
      setState(() {
        _doNotDisturbEnabled = dndEnabled;
        _doNotDisturbStart = dndStart != null 
            ? TimeOfDay(hour: dndStart ~/ 60, minute: dndStart % 60)
            : null;
        _doNotDisturbEnd = dndEnd != null 
            ? TimeOfDay(hour: dndEnd ~/ 60, minute: dndEnd % 60)
            : null;
      });
    }
  }

  Widget _buildPreferenceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppTheme.successColor.withValues(alpha: 179),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppTheme.errorColor.withValues(alpha: 179),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
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
                  size: 22,
                ),
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black45,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart 
          ? _doNotDisturbStart ?? const TimeOfDay(hour: 22, minute: 0)
          : _doNotDisturbEnd ?? const TimeOfDay(hour: 7, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        if (isStart) {
          _doNotDisturbStart = picked;
        } else {
          _doNotDisturbEnd = picked;
        }
      });
      
      final minutes = picked.hour * 60 + picked.minute;
      if (isStart) {
        await _preferencesService.setDoNotDisturbStart(minutes);
      } else {
        await _preferencesService.setDoNotDisturbEnd(minutes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          children: [
            _buildPreferenceOption(
              icon: Icons.notifications_rounded,
              title: 'Notifiche Generali',
              subtitle: 'Attiva o disattiva tutte le notifiche',
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _preferencesService.setNotificationsEnabled(value);
              },
              description: 'Controlla tutte le notifiche dell\'app',
            ),
            if (_notificationsEnabled) ...[
              _buildPreferenceOption(
                icon: Icons.system_update_rounded,
                title: 'Notifiche di Sistema',
                subtitle: 'Aggiornamenti e informazioni importanti',
                value: _systemNotifications,
                onChanged: (value) async {
                  setState(() => _systemNotifications = value);
                  await _preferencesService.setSystemNotifications(value);
                },
              ),
              _buildPreferenceOption(
                icon: Icons.emoji_events_rounded,
                title: 'Notifiche Quest',
                subtitle: 'Aggiornamenti su missioni e obiettivi',
                value: _questNotifications,
                onChanged: (value) async {
                  setState(() => _questNotifications = value);
                  await _preferencesService.setQuestNotifications(value);
                },
              ),
              _buildPreferenceOption(
                icon: Icons.message_rounded,
                title: 'Notifiche Messaggi',
                subtitle: 'Comunicazioni e messaggi dalla community',
                value: _messageNotifications,
                onChanged: (value) async {
                  setState(() => _messageNotifications = value);
                  await _preferencesService.setMessageNotifications(value);
                },
              ),
              _buildPreferenceOption(
                icon: Icons.campaign_rounded,
                title: 'Notifiche Promozionali',
                subtitle: 'Ricevi aggiornamenti su promozioni e novità',
                value: _promotionalNotifications,
                onChanged: (value) async {
                  setState(() => _promotionalNotifications = value);
                  await _preferencesService.setPromotionalNotifications(value);
                },
              ),
              _buildPreferenceOption(
                icon: Icons.do_not_disturb_on_rounded,
                title: 'Non Disturbare',
                subtitle: 'Silenzia le notifiche in orari specifici',
                value: _doNotDisturbEnabled,
                onChanged: (value) async {
                  setState(() => _doNotDisturbEnabled = value);
                  await _preferencesService.setDoNotDisturbEnabled(value);
                },
              ),
              if (_doNotDisturbEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(true),
                          child: Text(
                            _doNotDisturbStart != null 
                                ? 'Inizio: ${_doNotDisturbStart!.format(context)}'
                                : 'Imposta inizio',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _selectTime(false),
                          child: Text(
                            _doNotDisturbEnd != null 
                                ? 'Fine: ${_doNotDisturbEnd!.format(context)}'
                                : 'Imposta fine',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
} 