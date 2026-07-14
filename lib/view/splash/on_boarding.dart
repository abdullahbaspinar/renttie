import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renttie/constants/app_colors.dart';
import 'package:renttie/view/auth_choice/auth_choice.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthChoicePage()),
    );
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
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPageContent(context, onboardingData[index]);
                  },
                ),
              ),
              _buildDotIndicator(context),
              const SizedBox(height: 32),
              _buildActionButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 10.0),
        child: TextButton(
          onPressed: _finishOnboarding,
          child: const Text(
            'Geç',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.blur_circular,
                size: 280,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              Icon(
                item['icon'] as IconData,
                size: 160,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            item['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.secondary
                : AppColors.textHint(context).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.darkTextPrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            currentPage == onboardingData.length - 1 ? 'Hemen Başla' : 'İleri',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
