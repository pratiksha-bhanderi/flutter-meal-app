import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:provider/provider.dart';

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback? onTap;

  const MealCard({super.key, required this.meal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        if (onTap != null) onTap!();
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outline.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immersive Image Area
            Expanded(
              flex: 55,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.03),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: Image.asset(
                        meal['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: cs.onSurface.withOpacity(0.05),
                            child: Icon(
                              Icons.fastfood_rounded,
                              color: cs.primary.withOpacity(0.2),
                              size: context.sp(40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Favourites Heart Icon
                  Positioned(
                    top: context.h(10),
                    right: context.w(10),
                    child: Consumer<FavouritesProvider>(
                      builder: (context, favs, child) {
                        final isFav = favs.isFavourite(meal['name']!);
                        return GestureDetector(
                          onTap: () => favs.toggleFavourite(meal),
                          child: Container(
                            padding: EdgeInsets.all(context.w(8)),
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isFav
                                  ? Colors.red
                                  : (isDark ? Colors.white70 : Colors.black54),
                              size: context.sp(18),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Details Area
            Expanded(
              flex: 45,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(10),
                  context.h(8),
                  context.w(10),
                  context.h(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['name']!,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.h(2)),
                        Text(
                          '${meal['calories'] ?? '---'} kcal',
                          style: AppTextStyles.font(
                            context,
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          meal['price']!,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final quantity = cart.getItemQuantity(
                              meal['name']!,
                            );
                            if (quantity > 0) {
                              return Row(
                                children: [
                                  _quantityActionBtn(
                                    context,
                                    Icons.remove,
                                    () => cart.updateQuantity(
                                      cart.getItemIndex(meal['name']!),
                                      -1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.w(8),
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: AppTextStyles.font(
                                        context,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  _quantityActionBtn(
                                    context,
                                    Icons.add,
                                    () => cart.updateQuantity(
                                      cart.getItemIndex(meal['name']!),
                                      1,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                cart.addToCart(meal);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(14),
                                  vertical: context.h(6),
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ADD',
                                  style: AppTextStyles.font(
                                    context,
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityActionBtn(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.w(4)),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryOrange, size: context.sp(16)),
      ),
    );
  }
}
