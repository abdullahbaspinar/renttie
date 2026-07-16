import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_radius.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';
import 'package:renttie/core/router/app_refresh.dart';
import 'package:renttie/core/router/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.add_home_work_outlined,
      'title': 'Tüm Mülklerinizi Tek Yerden Yönetin',
      'description':
          "Ev, ofis veya dükkan... Portföyünüzdeki tüm taşınmazları Renttie'ye ekleyin, karmaşaya son verin.",
    },
    {
      'icon': Icons.history_edu_outlined,
      'title': 'Kira Sözleşmelerini Dijitalleştirin',
      'description':
          'Kontrat sürelerini, depozito bilgilerini ve kritik maddeleri güvenle saklayın. Bitiş tarihlerini kaçırmayın.',
    },
    {
      'icon': Icons.notifications_active_outlined,
      'title': 'Otomatik Hatırlatıcılarla Takibi Bırakın',
      'description':
          'Kira gününü veya sözleşme yenileme zamanını Renttie size ve kiracınıza hatırlatır. Stresi azaltın.',
    },
  ];

  Future<void> _finishOnboarding() async {
    await context.read<AppRouterRefresh>().completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.authChoice);
  }

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(context),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) =>
                      _buildPageContent(context, onboardingData[index]),
                ),
              ),
              _buildIndicators(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildNextButton(context),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(
          right: AppSpacing.xl,
          top: AppSpacing.md,
        ),
        child: TextButton(
          onPressed: _finishOnboarding,
          child: Text(
            'Atla',
            style: AppTypography.bodyLarge(
              color: AppColors.textSecondary(context),
            ).copyWith(fontWeight: AppTypography.semiBold),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: AppSpacing.horizontal(AppSpacing.huge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            data['icon'] as IconData,
            size: 100,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            data['title'] as String,
            textAlign: TextAlign.center,
            style: AppTypography.headline(
              color: AppColors.textPrimary(context),
            ).copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data['description'] as String,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: AppSpacing.horizontal(AppSpacing.xs + 1),
          height: AppSpacing.sm,
          width: currentPage == index ? AppSpacing.xxl : AppSpacing.sm,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.secondary
                : AppColors.border(context),
            borderRadius: AppRadius.mdAll,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final isLast = currentPage == onboardingData.length - 1;
    return Padding(
      padding: AppSpacing.horizontal(AppSpacing.xxl),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.darkTextPrimary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          ),
          child: Text(
            isLast ? 'Başla' : 'Devam',
            style: AppTypography.button(color: AppColors.darkTextPrimary),
          ),
        ),
      ),
    );
  }
}
