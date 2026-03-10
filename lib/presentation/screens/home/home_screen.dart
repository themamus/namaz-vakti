// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/next_prayer_card.dart';
import '../../widgets/prayer_times_list.dart';
import '../../widgets/date_header.dart';
import '../../widgets/ramadan_banner.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_shimmer.dart';
import '../qibla/qibla_screen.dart';
import '../settings/settings_screen.dart';
import '../calendar/calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrayerTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    final provider = context.read<PrayerTimesProvider>();
    final settings = context.read<SettingsProvider>();

    await provider.loadPrayerTimes(
      method: settings.appSettings.calculationMethod,
    );

    if (provider.status == PrayerTimesStatus.loaded) {
      _fadeController.forward();
      await provider.scheduleNotifications(settings);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PrayerTimesProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: LoadingShimmer(),
                )
              else if (provider.status == PrayerTimesStatus.error)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: provider.errorMessage ?? 'Bir hata oluştu',
                    onRetry: _loadPrayerTimes,
                  ),
                )
              else if (provider.prayerTimes != null) ...[
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        DateHeader(prayerTimes: provider.prayerTimes!),
                        if (provider.isRamadan)
                          RamadanBanner(prayerTimes: provider.prayerTimes!),
                        NextPrayerCard(provider: provider),
                        const SizedBox(height: 16),
                        PrayerTimesList(provider: provider),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildRefreshButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar(BuildContext context, PrayerTimesProvider provider) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🕌 Namaz Vakti',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (provider.location != null)
              Text(
                '📍 ${provider.location!.city}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ).then((_) => _loadPrayerTimes()),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            color: theme.colorScheme.primary,
            onPressed: () {},
            tooltip: 'Ana Sayfa',
          ),
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
            tooltip: 'Kıble',
          ),
          const SizedBox(width: 48), // Space for FAB
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
            tooltip: 'Takvim',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadPrayerTimes()),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return FloatingActionButton(
      onPressed: _loadPrayerTimes,
      tooltip: 'Yenile',
      child: const Icon(Icons.refresh),
    );
  }
}
