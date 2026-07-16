import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/model/payment.dart';
import 'package:renttie/view/home/widgets/app_header.dart';
import 'package:renttie/view/home/widgets/empty_state.dart';
import 'package:renttie/view/home/widgets/payment_card.dart';
import 'package:renttie/view/home/widgets/payment_detail_sheet.dart';
import 'package:renttie/view/home/widgets/summary_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        return Column(
          children: [
            AppHeader(user: user),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RentalState state) {
    if (state.status == RentalStatus.loading ||
        state.status == RentalStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        SummaryCard(summary: state.homeSummary),
        const SizedBox(height: 28),
        _buildSectionTitle(context),
        const SizedBox(height: AppSpacing.sm),
        if (state.upcomingPayments.isEmpty)
          const EmptyState(
            icon: Icons.payments_outlined,
            title: 'Yaklaşan ödeme yok',
            subtitle:
                'Tüm ödemeler tamamlandı veya henüz ödeme eklenmedi.',
          )
        else
          ...state.upcomingPayments.map(
            (payment) => _buildPaymentCard(context, state, payment),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Text(
      'Yaklaşan Ödemeler',
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    RentalState state,
    Payment payment,
  ) {
    final property = state.propertyById(payment.propertyId);
    final tenant = state.tenantById(payment.tenantId);

    return PaymentCard(
      title: '${property?.name ?? ''} - ${tenant?.name ?? ''}',
      dueDate: formatShortDate(payment.dueDate),
      amount: payment.amount,
      status: payment.status,
      isProrated: payment.isProrated,
      onTap: () => PaymentDetailSheet.show(context, payment.id),
      showMessageAction: payment.status == PaymentStatus.overdue,
      onMessageTap: () async {
        await context.read<RentalCubit>().markPaymentMessage(payment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${tenant?.name ?? 'Kiracı'} için mesaj işaretlendi',
              ),
            ),
          );
        }
      },
    );
  }
}
