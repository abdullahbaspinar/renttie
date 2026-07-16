import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/view/home/widgets/app_header.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _notifications = [
    _NotificationItem(
      title: 'Kira Hatırlatıcısı',
      body: 'Ofis B - Can Polat kirası 5 gün gecikti.',
      time: '2 saat önce',
      isUnread: true,
    ),
    _NotificationItem(
      title: 'Yaklaşan Ödeme',
      body: 'Daire 3A kirası 15 Temmuz\'da vadesi doluyor.',
      time: 'Dün',
      isUnread: true,
    ),
    _NotificationItem(
      title: 'Ödeme Alındı',
      body: 'Daire 3A - Ayşe Yılmaz ödemesi tamamlandı.',
      time: '3 gün önce',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppHeaderScaffold(
      user: null,
      title: 'Bildirimler',
      child: ListView.separated(
        padding: AppSpacing.section,
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Container(
            padding: AppSpacing.page,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: item.isUnread
                    ? AppColors.accent.withValues(alpha: 0.4)
                    : AppColors.border(context),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.body,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: AppTypography.sizeMd,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.time,
                        style: AppTypography.caption(color: AppColors.textHint(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });

  final String title;
  final String body;
  final String time;
  final bool isUnread;
}
