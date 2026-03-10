// lib/presentation/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, 'Konum'),
              _buildLocationCard(context),

              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Hesaplama Yöntemi'),
              _buildCalculationMethodCard(context, settings),

              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Bildirimler'),
              _buildNotificationsCard(context, settings),

              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Vakit Bildirimleri'),
              _buildPrayerNotificationsCard(context, settings),

              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Görünüm'),
              _buildAppearanceCard(context, settings),

              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Ezan Sesi'),
              _buildAzanSoundCard(context, settings),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Konumu Güncelle'),
            subtitle: const Text('GPS ile konumu yenile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final provider = context.read<PrayerTimesProvider>();
              final settings = context.read<SettingsProvider>();
              await provider.loadPrayerTimes(
                method: settings.appSettings.calculationMethod,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Konum güncellendi')),
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Şehir Ara'),
            subtitle: const Text('Manuel şehir seçimi yap'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCitySearch(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodCard(
      BuildContext context, SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Mevcut: ${AppConstants.calculationMethods[settings.appSettings.calculationMethod]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ...AppConstants.calculationMethods.entries.map((entry) {
              return RadioListTile<int>(
                title: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 14),
                ),
                value: entry.key,
                groupValue: settings.appSettings.calculationMethod,
                activeColor: AppTheme.primaryGreen,
                dense: true,
                onChanged: (value) async {
                  if (value != null) {
                    await settings.setCalculationMethod(value);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(
      BuildContext context, SettingsProvider settings) {
    return Card(
      child: SwitchListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Tüm Bildirimleri Etkinleştir'),
        subtitle: const Text('Namaz vakti bildirimlerini aç/kapat'),
        value: settings.appSettings.notificationsEnabled,
        activeColor: AppTheme.primaryGreen,
        onChanged: (value) async {
          await settings.setNotificationsEnabled(value);
        },
      ),
    );
  }

  Widget _buildPrayerNotificationsCard(
      BuildContext context, SettingsProvider settings) {
    const prayers = [
      ('imsak', 'İmsak', Icons.dark_mode_outlined),
      ('sunrise', 'Güneş', Icons.wb_sunny_outlined),
      ('dhuhr', 'Öğle', Icons.light_mode_outlined),
      ('asr', 'İkindi', Icons.wb_cloudy_outlined),
      ('maghrib', 'Akşam', Icons.nights_stay_outlined),
      ('isha', 'Yatsı', Icons.bedtime_outlined),
    ];

    return Card(
      child: Column(
        children: prayers.asMap().entries.map((entry) {
          final index = entry.key;
          final (key, name, icon) = entry.value;
          final isEnabled =
              settings.appSettings.prayerNotifications[key] ?? false;
          final isVibration =
              settings.appSettings.prayerVibration[key] ?? false;

          return Column(
            children: [
              ListTile(
                leading: Icon(icon, size: 20),
                title: Text(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vibration toggle
                    IconButton(
                      icon: Icon(
                        isVibration ? Icons.vibration : Icons.vibration,
                        color: isVibration
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                        size: 18,
                      ),
                      onPressed: () async {
                        await settings.setPrayerVibration(key, !isVibration);
                      },
                      tooltip: 'Titreşim',
                    ),
                    Switch(
                      value: isEnabled,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: settings.appSettings.notificationsEnabled
                          ? (value) async {
                              await settings.setPrayerNotification(key, value);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              if (index < prayers.length - 1)
                const Divider(height: 1, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppearanceCard(
      BuildContext context, SettingsProvider settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Karanlık Mod'),
            value: settings.appSettings.darkMode,
            activeColor: AppTheme.primaryGreen,
            onChanged: (value) async {
              await settings.setDarkMode(value);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Dil'),
            trailing: DropdownButton<String>(
              value: settings.appSettings.language,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (lang) async {
                if (lang != null) await settings.setLanguage(lang);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzanSoundCard(
      BuildContext context, SettingsProvider settings) {
    const sounds = [
      ('azan_default', 'Varsayılan Ezan'),
      ('azan_mecca', 'Mekke Ezanı'),
      ('azan_medina', 'Medine Ezanı'),
      ('azan_turkey', 'Türkiye Ezanı'),
    ];

    return Card(
      child: Column(
        children: sounds.asMap().entries.map((entry) {
          final index = entry.key;
          final (key, name) = entry.value;
          return Column(
            children: [
              RadioListTile<String>(
                title: Text(name),
                value: key,
                groupValue: settings.appSettings.azanSound,
                activeColor: AppTheme.primaryGreen,
                secondary: IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () {
                    // Play preview
                  },
                ),
                onChanged: (value) async {
                  if (value != null) await settings.setAzanSound(value);
                },
              ),
              if (index < sounds.length - 1)
                const Divider(height: 1, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCitySearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Şehir Ara'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Şehir adı girin...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (_) =>
                  _searchCity(context, ctx, controller.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _searchCity(context, ctx, controller.text),
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchCity(
      BuildContext context, BuildContext dialogContext, String city) async {
    if (city.trim().isEmpty) return;

    Navigator.pop(dialogContext);
    final settings = context.read<SettingsProvider>();
    final provider = context.read<PrayerTimesProvider>();

    await provider.loadPrayerTimesByCity(
      city: city.trim(),
      country: 'Turkey',
      method: settings.appSettings.calculationMethod,
    );
  }
}
