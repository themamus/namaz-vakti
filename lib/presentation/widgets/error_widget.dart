// lib/presentation/widgets/error_widget.dart

import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  IconData _getIconForError(String message) {
    if (message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('bağlantı') ||
        message.toLowerCase().contains('network')) {
      return Icons.wifi_off_rounded;
    } else if (message.toLowerCase().contains('konum') ||
        message.toLowerCase().contains('gps') ||
        message.toLowerCase().contains('location')) {
      return Icons.location_off_rounded;
    } else if (message.toLowerCase().contains('izin') ||
        message.toLowerCase().contains('permission')) {
      return Icons.lock_outline_rounded;
    } else if (message.toLowerCase().contains('sunucu') ||
        message.toLowerCase().contains('server')) {
      return Icons.cloud_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getIconForError(message);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bir Sorun Oluştu',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate to manual city search
              },
              child: const Text('Manuel Şehir Seç'),
            ),
          ],
        ),
      ),
    );
  }
}
