import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/history_provider.dart';
import 'package:meal_app/core/providers/data_provider.dart';
import 'package:provider/provider.dart';

class MealDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> meals;
  final int initialIndex;

  const MealDetailScreen({
    super.key,
    required this.meals,
    required this.initialIndex,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Add initial meal to history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().addToRecentlyViewed(widget.meals[_currentIndex]);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.meals.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Force light text on dark background for this immersive screen
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface, // Dark matching the mockup
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                context.read<HistoryProvider>().addToRecentlyViewed(widget.meals[index]);
              },
              itemCount: widget.meals.length,
              itemBuilder: (context, index) {
                return _buildMealPage(context, widget.meals[index]);
              },
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + context.h(10),
              left: context.w(24),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: context.w(48),
                  height: context.w(48),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : Colors.black,
                    size: context.sp(20),
                  ),
                ),
              ),
            ),

            // Left Arrow (only if not at start)
            if (_currentIndex > 0)
              Positioned(
                left: 0,
                top: context.h(400),
                child: GestureDetector(
                  onTap: _goToPrevious,
                  child: Container(
                    width: context.w(36),
                    height: context.h(60),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkGrey
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: context.sp(20),
                    ),
                  ),
                ),
              ),

            // Right Arrow (only if not at end)
            if (_currentIndex < widget.meals.length - 1)
              Positioned(
                right: 0,
                top: context.h(400),
                child: GestureDetector(
                  onTap: _goToNext,
                  child: Container(
                    width: context.w(36),
                    height: context.h(60),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkGrey
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: context.sp(20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPage(BuildContext context, Map<String, dynamic> meal) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calories = meal['calories'] ?? '250';
    final category = meal['category'] ?? 'Salad & Vegetables';

    return Column(
      children: [
        // Top Image Area
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Image
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(meal['image']!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Dark gradient over image to fade into bottom part
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              cs.surface,
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.grey.withValues(alpha: 0.0),
                              cs.surface,
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Category Pill positioned between the scroll arrows
              Positioned(
                bottom: context.h(24),
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(16),
                      vertical: context.h(8),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.font(
                        context,
                        color: AppColors.secondaryOrange,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Details Area
        Expanded(
          flex: 45,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: cs.surface),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Column(
                  children: [
                    // SizedBox(height: context.h(20)),

                    // Title
                    Text(
                      meal['name']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font(
                        context,
                        color: cs.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: context.h(24)),

                    // Nutrients Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutrientCard(
                            context,
                            '120g',
                            'Protein',
                            const Color(0xFFFF5252),
                            0.6,
                          ),
                        ),
                        SizedBox(width: context.w(12)),
                        Expanded(
                          child: _buildNutrientCard(
                            context,
                            '50g',
                            'Carbs',
                            const Color(0xFF448AFF),
                            0.4,
                          ),
                        ),
                        SizedBox(width: context.w(12)),
                        Expanded(
                          child: _buildNutrientCard(
                            context,
                            '8g',
                            'Nutrients',
                            const Color(0xFFFFC107),
                            0.2,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.h(24)),

                    // Action Buttons
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Consumer<CartProvider>(
                                builder: (context, cart, child) {
                                  final quantity = cart.getItemQuantity(meal['name']!);
                                  if (quantity > 0) {
                                    return Container(
                                      height: context.h(56),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.primaryOrange, width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            onPressed: () => cart.updateQuantity(cart.getItemIndex(meal['name']!), -1),
                                            icon: const Icon(Icons.remove, color: AppColors.primaryOrange),
                                          ),
                                          Text(
                                            '$quantity',
                                            style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w800),
                                          ),
                                          IconButton(
                                            onPressed: () => cart.updateQuantity(cart.getItemIndex(meal['name']!), 1),
                                            icon: const Icon(Icons.add, color: AppColors.primaryOrange),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return SizedBox(
                                    height: context.h(56),
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        cart.addToCart(meal);
                                      },
                                      icon: Icon(
                                        Icons.add_shopping_cart_rounded,
                                        size: context.sp(18),
                                      ),
                                      label: Text(
                                        'Add to Cart',
                                        style: AppTextStyles.font(
                                          context,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryOrange,
                                        side: const BorderSide(
                                          color: AppColors.primaryOrange,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: context.w(12)),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: context.h(56),
                                child: OutlinedButton.icon(
                                  onPressed: () => _showMealDetailsBottomSheet(
                                    context,
                                    meal,
                                  ),
                                  icon: Icon(
                                    Icons.info_outline_rounded,
                                    size: context.sp(20),
                                  ),
                                  label: Text(
                                    'Details',
                                    style: AppTextStyles.font(
                                      context,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.secondaryOrange,
                                    side: const BorderSide(
                                      color: AppColors.secondaryOrange,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(16)),
                        SizedBox(
                          width: double.infinity,
                          height: context.h(60),
                          child: ElevatedButton(
                            onPressed: () async {
                              await context.read<CartProvider>().addToCart(meal);
                              if (mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                Navigator.of(context).pushNamed(AppRouter.cart);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.primaryOrange.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Buy Now',
                                  style: AppTextStyles.font(
                                    context,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: context.w(12)),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: context.sp(22),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.h(40)),

                    // Similar Items
                    _buildSimilarItems(context, meal),

                    SizedBox(
                      height:
                          context.h(40) + MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String value,
    String label,
    Color color,
    double progress,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.h(16),
        horizontal: context.w(8),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkGrey.withValues(alpha: 0.3)
            : cs.onSurface.withValues(
                alpha: 0.05,
              ), // Match the dark background of the card
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.font(
              context,
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.h(6)),
          Text(
            label,
            style: AppTextStyles.font(
              context,
              color: cs.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.h(14)),
          // Progress bar
          Stack(
            children: [
              Container(
                height: context.h(6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : cs.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  height: context.h(6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMealDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> meal,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(context.w(24)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: context.w(40),
                height: context.h(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        meal['name'] ?? 'Bison Burger',
                        style: AppTextStyles.font(
                          context,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: context.w(8)),
                      Text('🔥', style: TextStyle(fontSize: context.sp(20))),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: context.w(4)),
                    Text(
                      '5.0',
                      style: AppTextStyles.font(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.secondaryOrange,
                      size: context.sp(20),
                    ),
                    SizedBox(width: context.w(6)),
                    Text(
                      '30min',
                      style: AppTextStyles.font(
                        context,
                        color: cs.onSurface.withValues(alpha: 0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(16),
                  ),
                  child: Text(
                    '•',
                    style: AppTextStyles.font(
                      context,
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: AppColors.blueAccent,
                      size: context.sp(20),
                    ),
                    SizedBox(width: context.w(6)),
                    Text(
                      '${meal['calories'] ?? '250'} kcal',
                      style: AppTextStyles.font(
                        context,
                        color: cs.onSurface.withValues(alpha: 0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.h(24)),
            Text(
              'About this Meal',
              style: AppTextStyles.font(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
            ),
            SizedBox(height: context.h(12)),
            Text(
              'This delicious ${meal['name'] ?? 'meal'} is packed with fresh ingredients, bringing a vibrant burst of flavor to your palate. Perfectly balanced for a healthy lifestyle, it features organic produce hand-selected for optimal nutritional value and taste.',
              style: AppTextStyles.font(
                context,
                fontSize: 15,
                height: 1.6,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: context.h(24)),
            SizedBox(
              width: double.infinity,
              height: context.h(50),
              child: OutlinedButton.icon(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  Navigator.pop(context);
                  navigator.pushNamed(
                    AppRouter.ingredientSelection,
                    arguments: meal,
                  );
                },
                icon: Icon(Icons.auto_awesome_outlined, size: context.sp(18)),
                label: Text(
                  'Customize Ingredients',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            SizedBox(height: context.h(32)),
            
            // Reviews Section
            Text(
              'Ratings & Reviews',
              style: AppTextStyles.font(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: context.h(16)),
            _buildReviewItem(
              context,
              'Sarah Johnson',
              'The flavor was absolutely incredible! Best bison burger I\'ve ever had.',
              5,
              cs,
            ),
            SizedBox(height: context.h(12)),
            _buildReviewItem(
              context,
              'Mike Ross',
              'Perfectly balanced ingredients. Arrived hot and fresh.',
              4,
              cs,
            ),

            SizedBox(
              height: context.h(24) + MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildReviewItem(BuildContext context, String name, String comment, int stars, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: cs.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < stars ? Colors.orange : Colors.grey.withOpacity(0.3),
                    size: context.sp(16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(8)),
          Text(
            comment,
            style: AppTextStyles.font(
              context,
              fontSize: 13,
              color: cs.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItems(BuildContext context, Map<String, dynamic> currentMeal) {
    final cs = Theme.of(context).colorScheme;
    final data = Provider.of<DataProvider>(context, listen: false);
    final similar = data.meals
        .where((m) => m['category'] == currentMeal['category'] && m['name'] != currentMeal['name'])
        .take(5)
        .toList();

    if (similar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You might also like',
          style: AppTextStyles.font(
            context,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: context.h(16)),
        SizedBox(
          height: context.h(160),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            itemBuilder: (context, index) {
              final meal = similar[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRouter.mealDetail,
                    arguments: {
                      'meals': [meal],
                      'index': 0,
                    },
                  );
                },
                child: Container(
                  width: context.w(130),
                  margin: EdgeInsets.only(right: context.w(16)),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.asset(
                          meal['image']!,
                          height: context.h(90),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(context.w(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['name']!,
                              style: AppTextStyles.font(context, fontSize: 11, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: context.h(4)),
                            Text(
                              meal['price']!,
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
            },
          ),
        ),
      ],
    );
  }
}
