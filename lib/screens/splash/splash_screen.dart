import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _rotateController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Subtle icon rotation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Short delay before starting
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // After splash duration, check auth and navigate
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    
    final loggedIn = await AuthService.isLoggedIn();
    final seenOnboarding = await AuthService.hasSeenOnboarding();

    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else if (!seenOnboarding) {
      Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepOrangeGradient, // Deep burnt orange
              AppColors.primaryOrange, // Vibrant orange
              AppColors.secondaryOrange, // Warm amber
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative circles
              ..._buildDecorativeCircles(context),

                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: _buildLogo(),
                            ),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.width * 0.08),

                          // App Name
                          SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textFade,
                              child: Text(
                                'MealMate',
                                style: AppTextStyles.font(context, 
                                  fontSize: MediaQuery.of(context).size.width * 0.1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: context.h(8)),

                          // Tagline
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              'Delicious meals, delivered fast',
                              style: AppTextStyles.font(context, 
                                fontSize: MediaQuery.of(context).size.width * 0.038,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

              // Bottom loading indicator
              Positioned(
                bottom: context.h(48),
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: context.w(32),
                        height: context.h(32),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                      Text(
                        'Loading your meals...',
                        style: AppTextStyles.font(context, 
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
   );
  }

  Widget _buildLogo() {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.3; // 30% of screen width

    return Container(
      width: logoSize,
      height: logoSize,
      constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: logoSize * 0.45,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles(BuildContext context) {
    return [
      Positioned(
        top: context.h(-60),
        right: context.w(-60),
        child: AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: child,
            );
          },
          child: Container(
            width: context.w(220),
            height: context.h(220),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 40,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: context.h(-80),
        left: context.w(-80),
        child: Container(
          width: context.w(280),
          height: context.h(280),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      Positioned(
        bottom: context.h(100),
        right: context.w(-30),
        child: Container(
          width: context.w(100),
          height: context.h(100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ),
    ];
  }
}
