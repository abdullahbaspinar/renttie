import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/bloc/rental/rental_state.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_size.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/view/home/finance_tab.dart';
import 'package:renttie/view/home/home_tab.dart';
import 'package:renttie/view/home/properties_tab.dart';
import 'package:renttie/view/home/tenants_tab.dart';
import 'package:renttie/view/home/widgets/quick_add_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _labels = ['Ana Sayfa', 'Mülklerim', 'Kiracılar', 'Finans'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final rentalCubit = context.read<RentalCubit>();
    if (rentalCubit.state.status == RentalStatus.initial) {
      rentalCubit.loadForUser(user?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final pages = [
      HomeTab(user: user),
      PropertiesTab(user: user),
      TenantsTab(user: user),
      FinanceTab(user: user),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => QuickAddSheet.show(context),
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 30),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface(context),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: const CircularNotchedRectangle(),
      notchMargin: AppSpacing.sm,
      child: SizedBox(
        height: AppSize.bottomNavHeight,
        child: Row(
          children: List.generate(_labels.length, (index) {
            return Expanded(child: _buildNavItem(context, index));
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final isActive = _currentIndex == index;
    final icon = switch (index) {
      0 => Icons.home_rounded,
      1 => Icons.apartment_outlined,
      2 => Icons.people_outline_rounded,
      _ => Icons.account_balance_wallet_outlined,
    };

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.accent : AppColors.textHint(context),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _labels[index],
            style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textHint(context),
              fontSize: AppTypography.sizeXs,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
