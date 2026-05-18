import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _next() {
    if (_currentPage < _PageData.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await AuthService.setOnboardingSeen();
    if (!mounted) return;
    
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      isLoggedIn ? AppRouter.home : AppRouter.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _PageData.pages.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _PageData.pages.length,
              itemBuilder: (_, i) =>
                  _buildPage(_PageData.pages[i], cs, i, isDark),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + context.h(16),
              right: context.w(24),
              child: AnimatedOpacity(
                opacity: isLast ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: GestureDetector(
                  onTap: _finish,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.font(context, 
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_PageData data, ColorScheme cs, int index, bool isDark) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double pageOffset = 0.0;
        if (_pageController.position.hasContentDimensions) {
          pageOffset = _pageController.page! - index;
        } else {
          pageOffset = (_currentPage - index).toDouble();
        }
        
        final double value = pageOffset;
        final double opacity = (1 - (value.abs() * 0.8)).clamp(0.0, 1.0);
        final double parallax = value * 150;

        final size = MediaQuery.of(context).size;
        final double screenWidth = size.width;

        Widget imageBlock = Stack(
          children: [
            ClipRRect(
              borderRadius: context.isDesktop 
                ? BorderRadius.zero 
                : const BorderRadius.only(
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(44),
                ),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(parallax * 0.5, 0.0, 0.0)
                  ..scale(1.0 + (value.abs() * 0.15), 1.0 + (value.abs() * 0.15), 1.0),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: opacity,
                  child: Image.asset(
                    data.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Soft dark overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: context.isDesktop ? Alignment.centerLeft : Alignment.topCenter,
                    end: context.isDesktop ? Alignment.centerRight : Alignment.center,
                    colors: [
                      context.isDesktop ? Colors.transparent : Colors.black.withValues(alpha: 0.3),
                      context.isDesktop ? cs.surface : Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

        Widget textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: context.isDesktop ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          mainAxisSize: context.isDesktop ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(parallax * 0.5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppTextStyles.font(context, 
                        fontSize: context.sp(30),
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    Text(
                      data.subtitle,
                      style: AppTextStyles.font(context, 
                        fontSize: context.sp(15),
                        color: cs.onSurface.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.isDesktop ? context.h(64) : context.h(32)),
            Row(
              children: [
                Row(
                  children: List.generate(_PageData.pages.length, (i) {
                    final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: EdgeInsets.only(right: context.w(6)),
                        width: active ? context.w(28) : context.w(8),
                        height: context.h(8),
                        decoration: BoxDecoration(
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _next,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: context.h(58),
                    width: _currentPage == _PageData.pages.length - 1 ? context.w(160) : context.w(58),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _currentPage == _PageData.pages.length - 1
                          ? Text(
                              'Get Started',
                              style: AppTextStyles.font(context, 
                                color: Colors.white,
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: context.sp(26),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (context.isDesktop) {
          return Row(
            children: [
              Expanded(
                flex: 5,
                child: imageBlock,
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: cs.surface,
                  padding: EdgeInsets.symmetric(horizontal: context.w(48), vertical: context.h(48)),
                  child: Center(
                    child: textBlock,
                  ),
                ),
              ),
            ],
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double imageHeight = math.max(250.0, constraints.maxHeight * 0.55);
            final double remainingHeight = constraints.maxHeight - imageHeight;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: imageBlock,
                  ),
                  Container(
                    width: double.infinity,
                    color: cs.surface,
                    constraints: BoxConstraints(
                      minHeight: math.max(0.0, remainingHeight),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      context.w(32),
                      context.h(32),
                      context.w(32),
                      context.h(48),
                    ),
                    child: textBlock,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

class _PageData {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;

  _PageData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
  });

  static final List<_PageData> pages = [
    _PageData(
      title: 'Delicious Meals\nat Your Fingertips',
      subtitle: 'Explore thousands of curated recipes and restaurants near you.',
      imagePath: 'assets/images/onboarding/burger.png',
      gradientColors: [AppColors.primaryOrange, AppColors.secondaryOrange],
    ),
    _PageData(
      title: 'Healthy Choices\nfor a Better You',
      subtitle: 'Customize your meals based on your dietary needs and goals.',
      imagePath: 'assets/images/onboarding/salad.png',
      gradientColors: [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
    ),
    _PageData(
      title: 'Fast Delivery\nto Your Doorstep',
      subtitle: 'Real-time tracking and lightning fast delivery for every order.',
      imagePath: 'assets/images/onboarding/delivery.png',
      gradientColors: [const Color(0xFF1565C0), AppColors.blueAccent],
    ),
  ];
}
