import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/widgets/meal_card.dart';
import 'package:meal_app/core/providers/data_provider.dart';
import 'package:meal_app/core/providers/history_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? _userEmail;
  String _selectedCategory = 'All';
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(hours: 2, minutes: 34, seconds: 10);
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _loadUserData();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _loadUserData() async {
    final email = await AuthService.getUserEmail();
    if (mounted) setState(() => _userEmail = email);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  void dispose() {
    _animController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = _userEmail?.split('@').first ?? 'there';
    final data = Provider.of<DataProvider>(context);

    if (data.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter meals based on selected category and limit to first 4 for dashboard
    final filteredMeals = data.getMealsByCategory(_selectedCategory);
    final displayedMeals = filteredMeals.take(4).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                // Top bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(20),
                      context.w(24),
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good day, $firstName! 👋',
                                style: AppTextStyles.font(
                                  context,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: context.h(2)),
                              Text(
                                'What would you like to eat today?',
                                style: AppTextStyles.font(
                                  context,
                                  fontSize: 13,
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).pushNamed(AppRouter.notifications);
                          },
                          icon: Badge(
                            label: const Text('2', style: TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: AppColors.primaryOrange,
                            child: Icon(
                              Icons.notifications_outlined,
                              color: cs.onSurface,
                              size: context.sp(26),
                            ),
                          ),
                        ),
                        SizedBox(width: context.w(4)),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).pushNamed(AppRouter.profile);
                          },
                          child: Container(
                            width: context.w(48),
                            height: context.w(48),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.primary.withOpacity(0.2),
                                width: 1.5,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://i.pravatar.cc/150?u=mealmate',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(24),
                      context.w(24),
                      0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pushNamed(AppRouter.explorer);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(16),
                          vertical: context.h(14),
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: cs.onSurface.withOpacity(0.4),
                              size: context.sp(22),
                            ),
                            SizedBox(width: context.w(12)),
                            Text(
                              'Search your favorite junk food...',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 14,
                                color: cs.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Promo and Flash Sale
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(24),
                      context.w(24),
                      0,
                    ),
                    child: Builder(
                      builder: (context) {
                        final promoBanner = Container(
                          height: context.h(170),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.deepOrangeGradient,
                                AppColors.secondaryOrange,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Container(
                                  width: context.w(130),
                                  height: context.h(130),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(20),
                                  vertical: context.h(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.w(10),
                                        vertical: context.h(3),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '🔥 Today\'s special',
                                        style: AppTextStyles.font(
                                          context,
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: context.h(8)),
                                    Text(
                                      'Up to 30% off\non your first order!',
                                      style: AppTextStyles.font(
                                        context,
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                    ),
                                    SizedBox(height: context.h(10)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.w(14),
                                        vertical: context.h(7),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Order Now',
                                        style: AppTextStyles.font(
                                          context,
                                          color: AppColors.primaryOrange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );

                        final flashSaleBanner = Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(20),
                            vertical: context.h(16),
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.primary.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: cs.primary,
                                size: context.sp(24),
                              ),
                              SizedBox(width: context.w(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Flash Sale ends in:',
                                      style: AppTextStyles.font(
                                        context,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(_remainingTime),
                                      style: AppTextStyles.font(
                                        context,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: cs.primary,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(12),
                                  vertical: context.h(8),
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'GRAB NOW',
                                  style: AppTextStyles.font(
                                    context,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (context.isDesktop) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 5, child: promoBanner),
                                SizedBox(width: context.w(16)),
                                Expanded(flex: 4, child: flashSaleBanner),
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              promoBanner,
                              SizedBox(height: context.h(16)),
                              flashSaleBanner,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),

                // Daily Deals section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(24),
                      context.w(24),
                      context.h(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Daily Deals',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(6),
                                vertical: context.h(2),
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '24h left',
                                style: AppTextStyles.font(
                                  context,
                                  fontSize: 10,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).pushNamed(AppRouter.explorer);
                          },
                          child: Text(
                            'See all',
                            style: AppTextStyles.font(
                              context,
                              fontSize: 13,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: context.h(140),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      itemCount: data.deals.length,
                      itemBuilder: (context, index) {
                        final deal = data.deals[index];
                        return _dealCard(context, deal, cs, index, data.deals);
                      },
                    ),
                  ),
                ),

                // Categories header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(28),
                      context.w(24),
                      context.h(12),
                    ),
                    child: Text(
                      'Categories',
                      style: AppTextStyles.font(
                        context,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: context.h(90),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                      children: [
                        _category(
                          context,
                          'assets/images/meals/all.png',
                          'All',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/pizza.png',
                          'Pizza',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/burger.png',
                          'Burgers',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/burger.png',
                          'Fries',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/noodles.png',
                          'Noodles',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/salad.png',
                          'Salads',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/dessert.png',
                          'Desserts',
                          cs,
                        ),
                        _category(
                          context,
                          'assets/images/meals/pasta.png',
                          'Pasta',
                          cs,
                        ),
                      ],
                    ),
                  ),
                ),

                // Popular header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.w(24),
                      context.h(20),
                      context.w(24),
                      context.h(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Meals',
                          style: AppTextStyles.font(
                            context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.of(context).pushNamed(AppRouter.explorer);
                          },
                          child: Text(
                            'See all',
                            style: AppTextStyles.font(
                              context,
                              fontSize: 13,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Meal grid
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(24),
                    0,
                    context.w(24),
                    0,
                  ), // Optimized bottom padding for floating bar
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.isDesktop ? 4 : 2,
                      crossAxisSpacing: context.w(14),
                      mainAxisSpacing: context.h(14),
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final meal = displayedMeals[index];
                      return MealCard(
                        meal: meal,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.mealDetail,
                            arguments: {
                              'meals': displayedMeals,
                              'index': index,
                            },
                          );
                        },
                      );
                    }, childCount: displayedMeals.length),
                  ),
                ),
                // Recently Viewed Section
                Consumer<HistoryProvider>(
                  builder: (context, history, child) {
                    if (history.recentlyViewed.isEmpty)
                      return const SliverToBoxAdapter(child: SizedBox.shrink());

                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              context.w(24),
                              context.h(28),
                              context.w(24),
                              0,
                            ),
                            child: Text(
                              'Recently Viewed',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: context.h(110),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(24),
                                vertical: context.h(12),
                              ),
                              itemCount: history.recentlyViewed.length,
                              itemBuilder: (context, index) {
                                final meal = history.recentlyViewed[index];
                                return _recentMealCard(context, meal, cs);
                              },
                            ),
                          ),
                          SizedBox(height: context.h(30)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recentMealCard(
    BuildContext context,
    Map<String, dynamic> meal,
    ColorScheme cs,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.mealDetail,
          arguments: {
            'meals': [meal],
            'index': 0,
          },
        );
      },
      child: Container(
        width: context.w(160),
        margin: EdgeInsets.only(right: context.w(12)),
        padding: EdgeInsets.all(context.w(8)),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                meal['image'],
                width: context.w(50),
                height: context.h(50),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: context.w(8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    meal['name'],
                    style: AppTextStyles.font(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.h(2)),
                  Text(
                    meal['price'],
                    style: AppTextStyles.font(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(44),
        height: context.h(44),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(icon, size: context.sp(20), color: color),
      ),
    );
  }

  Widget _dealCard(
    BuildContext context,
    Map<String, dynamic> deal,
    ColorScheme cs,
    int index,
    List<Map<String, dynamic>> allDeals,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.mealDetail,
          arguments: {'meals': allDeals, 'index': index},
        );
      },
      child: Container(
        width: context.w(280),
        margin: EdgeInsets.only(right: context.w(16)),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(context.w(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(8),
                            vertical: context.h(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            deal['off']!,
                            style: AppTextStyles.font(
                              context,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)),
                        Text(
                          deal['name']!,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.h(8)),
                        Row(
                          children: [
                            Text(
                              deal['price']!,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: cs.primary,
                              ),
                            ),
                            SizedBox(width: context.w(8)),
                            Text(
                              deal['oldPrice']!,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.4),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(20),
                    ),
                    child: Image.asset(
                      deal['image']!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _category(
    BuildContext context,
    String imagePath,
    String label,
    ColorScheme cs,
  ) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        setState(() => _selectedCategory = label);
      },
      child: Container(
        margin: EdgeInsets.only(right: context.w(12)),
        child: Column(
          children: [
            Container(
              width: context.w(56),
              height: context.h(56),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary.withOpacity(0.1) : cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: label == 'All'
                    ? Icon(
                        Icons.grid_view_rounded,
                        color: isSelected
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.5),
                        size: context.sp(30),
                      )
                    : Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: context.h(6)),
            Text(
              label,
              style: AppTextStyles.font(
                context,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
