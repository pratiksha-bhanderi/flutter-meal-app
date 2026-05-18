import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/screens/home/home_screen.dart';
import 'package:meal_app/screens/settings/settings_screen.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:provider/provider.dart';

import 'package:meal_app/screens/home/meal_explorer_screen.dart';
import 'package:meal_app/screens/home/favourites_screen.dart';
import 'package:meal_app/screens/home/cart_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() => _selectedIndex = widget.initialIndex);
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MealExplorerScreen(showBackButton: false),
    const CartScreen(showBackButton: false), // Orders/Cart
    const FavouritesScreen(showBackButton: false),
    const SettingsScreen(showBackButton: false), // Profile
  ];

  void _onItemTapped(int index) {
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _selectedIndex = index);

    // Update URL on web
    String route = AppRouter.home;
    if (index == 1) {
      route = AppRouter.explore;
    } else if (index == 2) {
      route = AppRouter.cart;
    } else if (index == 3) {
      route = AppRouter.favourites;
    } else if (index == 4) {
      route = AppRouter.settings;
    }

    // This updates the URL without triggering a full page transition
    SystemNavigator.routeInformationUpdated(location: route);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Row(
          children: [
            _buildSideDrawer(context, cs, isDark),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true, // Crucial for the floating look
      backgroundColor: cs.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, cs, isDark),
      floatingActionButton: _buildCartFAB(context, cs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSideDrawer(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          right: BorderSide(
            color: cs.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu_rounded, color: cs.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MealMate',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Items
          _drawerItem(context, 0, Icons.home_filled, 'Home', cs),
          _drawerItem(context, 1, Icons.search_rounded, 'Explore', cs),
          _drawerCartItem(context, 2, cs),
          _drawerItem(context, 3, Icons.favorite_outline_rounded, 'Favourites', cs),
          _drawerItem(context, 4, Icons.settings_outlined, 'Settings', cs),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, int index, IconData icon, String label, ColorScheme cs) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 4,
            ),
          ),
          color: isSelected ? cs.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.font(
                context,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerCartItem(BuildContext context, int index, ColorScheme cs) {
    final isSelected = _selectedIndex == index;
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return InkWell(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 4,
                ),
              ),
              color: isSelected ? cs.primary.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Cart',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                if (cart.itemCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartFAB(BuildContext context, ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedIndex == 2;
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                height: context.h(58),
                width: context.w(58),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: context.sp(28),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: context.w(12),
                        top: context.h(12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(10)), // Bottom margin
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, ColorScheme cs, bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: context.h(60) + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navItem(context, 0, Icons.home_filled, 'Home', cs),
              _navItem(context, 1, Icons.search_rounded, 'Explore', cs),
              SizedBox(width: context.w(64)), // Space for FAB
              _navItem(
                context,
                3,
                Icons.favorite_outline_rounded,
                'Favourites',
                cs,
              ),
              _navItem(context, 4, Icons.settings_outlined, 'Settings', cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    ColorScheme cs,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.4),
            size: context.sp(26),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.sp(80),
              color: cs.primary.withOpacity(0.2),
            ),
            SizedBox(height: context.h(16)),
            Text(
              title,
              style: AppTextStyles.font(
                context,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: context.h(8)),
            Text(
              'Feature coming soon...',
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
