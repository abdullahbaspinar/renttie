import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_routes.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/model/tenant.dart';
import 'package:renttie/services/contact_service.dart';

class TenantDetailPage extends StatelessWidget {
  const TenantDetailPage({super.key, required this.tenant});

  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        // Düzenleme sonrası güncel veriyi state'ten al.
        final current =
            state.tenants.where((t) => t.id == tenant.id).firstOrNull ??
                tenant;
        final property = state.propertyById(current.propertyId);
        final hasPhoto = current.photoPath != null &&
            File(current.photoPath!).existsSync();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            foregroundColor: AppColors.textPrimary(context),
            title: const Text('Kiracı Detayı'),
            actions: [
              IconButton(
                tooltip: 'Düzenle',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  AppRoutes.editTenantPath(current.id),
                  extra: current,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _buildAvatar(current, hasPhoto),
              const SizedBox(height: 18),
              _buildHeader(context, current, property?.name),
              const SizedBox(height: AppSpacing.xl),
              _buildContactButtons(context, current),
              const SizedBox(height: AppSpacing.lg),
              _buildPaymentHistoryButton(context, current),
              const SizedBox(height: 28),
              _InfoSection(
                title: 'Kira Bilgileri',
                children: [
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Aylık kira',
                    value: current.monthlyRent > 0
                        ? formatCurrency(current.monthlyRent)
                        : 'Belirtilmedi',
                  ),
                  _InfoRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Ödeme günü',
                    value: 'Her ayın ${current.paymentDay}. günü',
                  ),
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'Ödeme şekli',
                    value: current.paymentTimingLabel,
                  ),
                  _InfoRow(
                    icon: Icons.event_available_outlined,
                    label: 'Kira başlangıcı',
                    value: current.leaseStart != null
                        ? _formatDate(current.leaseStart!)
                        : 'Belirtilmedi',
                  ),
                  _InfoRow(
                    icon: Icons.event_busy_outlined,
                    label: 'Kira bitişi',
                    value: current.leaseEnd != null
                        ? _formatDate(current.leaseEnd!)
                        : 'Belirtilmedi',
                  ),
                  _InfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Depozito',
                    value: formatCurrency(current.depositAmount),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoSection(
                title: 'İletişim Bilgileri',
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Telefon',
                    value:
                        current.phone.isEmpty ? 'Belirtilmedi' : current.phone,
                  ),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'E-posta',
                    value:
                        current.email.isEmpty ? 'Belirtilmedi' : current.email,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoSection(
                title: 'Acil Durum Kişisi',
                children: [
                  _InfoRow(
                    icon: Icons.contact_emergency_outlined,
                    label: 'Ad Soyad',
                    value: (current.emergencyContactName?.trim().isNotEmpty ??
                            false)
                        ? current.emergencyContactName!
                        : 'Belirtilmedi',
                  ),
                  _EmergencyPhoneRow(
                    phone: current.emergencyContactPhone,
                  ),
                ],
              ),
              if (current.contractPath != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildContractTile(context, current),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day}.${date.month}.${date.year}';

  Widget _buildContactButtons(BuildContext context, Tenant tenant) {
    final hasPhone = tenant.phone.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: _ContactButton(
            icon: Icons.phone,
            label: 'Ara',
            color: AppColors.accent,
            onTap: hasPhone
                ? () async {
                    final ok = await ContactService.instance.call(tenant.phone);
                    if (!ok && context.mounted) {
                      _showError(context, 'Arama başlatılamadı');
                    }
                  }
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ContactButton(
            icon: Icons.chat,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: hasPhone
                ? () async {
                    final ok = await ContactService.instance.whatsApp(
                      tenant.phone,
                      message: 'Merhaba ${tenant.name},',
                    );
                    if (!ok && context.mounted) {
                      _showError(context, 'WhatsApp açılamadı');
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryButton(BuildContext context, Tenant tenant) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push(
          AppRoutes.tenantPaymentsPath(tenant.id),
          extra: tenant,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
          ),
        ),
        icon: const Icon(Icons.history),
        label: const Text(
          'Ödeme Geçmişi ve İstatistikler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildContractTile(BuildContext context, Tenant tenant) {
    final exists = File(tenant.contractPath!).existsSync();
    final fileName = tenant.contractPath!
        .split('/')
        .last
        .replaceFirst(RegExp(r'^\d+_'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kira Sözleşmesi',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: AppColors.surface(context),
          borderRadius: AppRadius.xlAll,
          child: ListTile(
            onTap: exists
                ? () => OpenFilex.open(tenant.contractPath!)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.xlAll,
              side: BorderSide(color: AppColors.border(context)),
            ),
            leading: const Icon(Icons.description, color: AppColors.secondary),
            title: Text(
              exists ? fileName : 'Dosya bulunamadı',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: AppTypography.sizeBase,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: exists
                ? Icon(Icons.open_in_new,
                    size: 18, color: AppColors.textHint(context))
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Tenant tenant, bool hasPhoto) {
    return Center(
      child: CircleAvatar(
        radius: 58,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
        backgroundImage: hasPhoto ? FileImage(File(tenant.photoPath!)) : null,
        child: hasPhoto
            ? null
            : Text(
                tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Tenant tenant, String? propertyName) {
    return Column(
      children: [
        Text(
          tenant.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          propertyName ?? 'Mülk bulunamadı',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? color.withValues(alpha: 0.12)
          : AppColors.border(context).withValues(alpha: 0.3),
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled ? color : AppColors.textHint(context),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : AppColors.textHint(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: AppRadius.xlAll,
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyPhoneRow extends StatelessWidget {
  const _EmergencyPhoneRow({required this.phone});

  final String? phone;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone?.trim().isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Icon(Icons.phone_outlined,
              color: AppColors.secondary, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Telefon',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          Text(
            hasPhone ? phone! : 'Belirtilmedi',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (hasPhone) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final ok = await ContactService.instance.call(phone!);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Arama başlatılamadı')),
                  );
                }
              },
              borderRadius: AppRadius.xxlAll,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call,
                    color: AppColors.accent, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
