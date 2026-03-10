// lib/presentation/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../../core/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const List<String> _hijriMonths = [
    '', 'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
    'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
    'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PrayerTimesProvider>();
    final prayerTimes = provider.prayerTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hicri Takvim'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: prayerTimes == null
          ? const Center(child: Text('Veri yüklenmedi'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hijri date card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'بسم الله الرحمن الرحيم',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontFamily: 'Scheherazade',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${prayerTimes.hijriDate.day}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _hijriMonths[prayerTimes.hijriDate.month] != ''
                                ? _hijriMonths[prayerTimes.hijriDate.month]
                                : prayerTimes.hijriDate.monthNameEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${prayerTimes.hijriDate.year} Hicri',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          Text(
                            '${prayerTimes.gregorianDate.day}.'
                            '${prayerTimes.gregorianDate.month}.'
                            '${prayerTimes.gregorianDate.year} Miladi',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hijri months info
                  Text(
                    'Hicri Aylar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: Column(
                      children: List.generate(12, (index) {
                        final monthNum = index + 1;
                        final isCurrentMonth =
                            monthNum == prayerTimes.hijriDate.month;
                        final isRamadan = monthNum == 9;

                        return Container(
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? AppTheme.primaryGreen.withOpacity(0.1)
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isCurrentMonth
                                    ? AppTheme.primaryGreen
                                    : (isRamadan
                                        ? AppTheme.accentGold.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$monthNum',
                                  style: TextStyle(
                                    color: isCurrentMonth
                                        ? Colors.white
                                        : (isRamadan
                                            ? AppTheme.darkGold
                                            : null),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              _hijriMonths[monthNum],
                              style: TextStyle(
                                fontWeight: isCurrentMonth || isRamadan
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentMonth
                                    ? AppTheme.primaryGreen
                                    : null,
                              ),
                            ),
                            trailing: isRamadan
                                ? const Text('🌙',
                                    style: TextStyle(fontSize: 20))
                                : isCurrentMonth
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppTheme.primaryGreen,
                                      )
                                    : null,
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Special Islamic days info
                  Text(
                    'Önemli Günler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecialDaysCard(context),
                ],
              ),
            ),
    );
  }

  Widget _buildSpecialDaysCard(BuildContext context) {
    final specialDays = [
      ('1 Muharrem', 'Hicri Yılbaşı', '🎊'),
      ('10 Muharrem', 'Aşure Günü', '🌊'),
      ('12 Rebiülevvel', 'Mevlid Kandili', '🌙'),
      ('27 Recep', 'Regaib Kandili', '⭐'),
      ('1 Şaban', 'Berat Kandili başlangıcı', '🕯️'),
      ('15 Şaban', 'Berat Kandili', '🕯️'),
      ('1 Ramazan', 'Ramazan başlangıcı', '🌙'),
      ('27 Ramazan', 'Kadir Gecesi', '✨'),
      ('1 Şevval', 'Ramazan Bayramı', '🎉'),
      ('9 Zilhicce', 'Arefe Günü', '🕌'),
      ('10 Zilhicce', 'Kurban Bayramı', '🐑'),
    ];

    return Card(
      child: Column(
        children: specialDays.asMap().entries.map((entry) {
          final index = entry.index;
          final (date, name, emoji) = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (index < specialDays.length - 1)
                const Divider(height: 1, indent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
