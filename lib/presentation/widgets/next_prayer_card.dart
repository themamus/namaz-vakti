// lib/presentation/widgets/next_prayer_card.dart

import 'package:flutter/material.dart';
import '../providers/prayer_times_provider.dart';
import '../../core/theme/app_theme.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerTimesProvider provider;

  const NextPrayerCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final next = provider.nextPrayer;
    if (next == null) return const SizedBox.shrink();

    final gradient = AppTheme.prayerCardGradients[next.index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sıradaki Vakit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      next.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    next.time,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Kalan Süre: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    provider.formatCountdown(),
                    key: ValueKey(provider.formatCountdown()),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// lib/presentation/widgets/prayer_times_list.dart
// (In separate file in real project, combined here for brevity)
class PrayerTimesList extends StatelessWidget {
  final PrayerTimesProvider provider;

  const PrayerTimesList({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final prayerTimes = provider.prayerTimes!.prayerTimesList;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Günlük Vakitler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...prayerTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final prayer = entry.value;
              final isNext = provider.nextPrayer?.index == prayer.index;
              final isPast = prayer.isPast &&
                  provider.nextPrayer?.index != prayer.index;

              return _PrayerTimeRow(
                prayer: prayer,
                isNext: isNext,
                isPast: isPast,
                isLast: index == prayerTimes.length - 1,
                isDark: isDark,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  final dynamic prayer;
  final bool isNext;
  final bool isPast;
  final bool isLast;
  final bool isDark;

  const _PrayerTimeRow({
    required this.prayer,
    required this.isNext,
    required this.isPast,
    required this.isLast,
    required this.isDark,
  });

  static const List<IconData> _prayerIcons = [
    Icons.dark_mode_outlined,  // İmsak
    Icons.wb_sunny_outlined,    // Güneş
    Icons.light_mode_outlined,  // Öğle
    Icons.wb_cloudy_outlined,   // İkindi
    Icons.nights_stay_outlined, // Akşam
    Icons.bedtime_outlined,     // Yatsı
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = isNext
        ? AppTheme.prayerCardGradients[prayer.index].first.withOpacity(0.1)
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Prayer icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isNext
                        ? AppTheme.prayerCardGradients[prayer.index].first
                            .withOpacity(0.15)
                        : (isDark
                            ? Colors.white10
                            : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _prayerIcons[prayer.index],
                    color: isNext
                        ? AppTheme.prayerCardGradients[prayer.index].first
                        : (isPast
                            ? theme.colorScheme.onSurface.withOpacity(0.4)
                            : theme.colorScheme.onSurface),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Prayer name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          color: isPast
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        prayer.nameEn,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      prayer.time,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPast
                            ? theme.colorScheme.onSurface.withOpacity(0.4)
                            : isNext
                                ? AppTheme.prayerCardGradients[prayer.index]
                                    .first
                                : theme.colorScheme.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (isNext)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.prayerCardGradients[prayer.index].first,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sıradaki',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              indent: 76,
              color: theme.dividerColor.withOpacity(0.5),
            ),
        ],
      ),
    );
  }
}

// lib/presentation/widgets/date_header.dart
class DateHeader extends StatelessWidget {
  final dynamic prayerTimes;

  const DateHeader({super.key, required this.prayerTimes});

  static const List<String> _turkishMonths = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  static const List<String> _hijriMonths = [
    '', 'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
    'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
    'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gregorian = prayerTimes.gregorianDate;
    final hijri = prayerTimes.hijriDate;

    final monthName = _turkishMonths[gregorian.month];
    final hijriMonthName = hijri.month <= 12
        ? _hijriMonths[hijri.month]
        : hijri.monthNameEn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gregorian.day} $monthName ${gregorian.year}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${hijri.day} $hijriMonthName ${hijri.year} H.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/presentation/widgets/ramadan_banner.dart
class RamadanBanner extends StatelessWidget {
  final dynamic prayerTimes;

  const RamadanBanner({super.key, required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ramazan Ayı',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'İmsak',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            prayerTimes.imsak,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'İftar',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            prayerTimes.maghrib,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/presentation/widgets/loading_shimmer.dart
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Namaz vakitleri yükleniyor...'),
        ],
      ),
    );
  }
}
