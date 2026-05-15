import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:provider/provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/router/app_router.dart';


class FavouritesScreen extends StatelessWidget {
  final bool showBackButton;
  const FavouritesScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<FavouritesProvider>(
      builder: (context, favs, child) {
        final favouriteMeals = favs.favouriteMeals;
        
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: showBackButton ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ) : null,
            automaticallyImplyLeading: false,
            title: Text(
              'Favourites',
              style: AppTextStyles.font(
                context,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: favouriteMeals.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(40)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/empty_favourites.png',
                          width: context.w(220),
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.favorite_border_rounded,
                            size: context.sp(80),
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        SizedBox(height: context.h(32)),
                        Text(
                          'Save your faves',
                          style: AppTextStyles.font(
                            context,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: context.h(12)),
                        Text(
                          'Tap the heart icon on any meal to save it here for later.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(context.w(24)),
                  itemCount: favouriteMeals.length,
                  itemBuilder: (context, index) {
                    final meal = favouriteMeals[index];
                    return _buildFavCard(context, meal, favs, isDark);
                  },
                ),
        );
      },
    );
  }

  Widget _buildFavCard(BuildContext context, Map<String, dynamic> meal, FavouritesProvider favs, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.mealDetail,
          arguments: {
            'meals': favs.favouriteMeals,
            'index': favs.favouriteMeals.indexOf(meal),
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(20)),
        padding: EdgeInsets.all(context.w(12)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                meal['image'],
                width: context.w(100),
                height: context.w(100),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'],
                    style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    meal['category'],
                    style: AppTextStyles.font(context, fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: context.h(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        meal['price'],
                        style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryOrange),
                      ),
                      IconButton(
                        onPressed: () => favs.toggleFavourite(meal),
                        icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _mockFavourites = [
    {
      'name': 'Classic Beef Burger',
      'category': 'Burgers',
      'price': '\$12.99',
      'image': 'assets/images/meals/burger.png',
    },
    {
      'name': 'Margherita Pizza',
      'category': 'Pizza',
      'price': '\$14.50',
      'image': 'assets/images/meals/pizza.png',
    },
  ];
}
