import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;
  const CartScreen({super.key, this.showBackButton = true});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface,
        resizeToAvoidBottomInset: true, // Allow resizing for keyboard
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.showBackButton ? IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.pop(context);
            },
          ) : null,
          automaticallyImplyLeading: false,
          title: !context.isDesktop ? Text(
            'Cart',
            style: AppTextStyles.font(
              context,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ) : null,
          toolbarHeight: context.isDesktop ? 0 : context.h(80),
        ),
        body: cart.items.isEmpty
            ? _buildEmptyState(context, isDark)
            : SafeArea(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.isDesktop ? 1200 : 800),
                    child: context.isDesktop
                        ? Padding(
                            padding: EdgeInsets.all(context.w(24)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: context.h(32)),
                                  child: Text(
                                    'Cart',
                                    style: AppTextStyles.font(
                                      context,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Left Side: Cart Items
                                      Expanded(
                                        flex: 3,
                                        child: _buildCartList(context, cart, isDark),
                                      ),
                                      SizedBox(width: context.w(32)),
                                      // Right Side: Billing Summary
                                      Expanded(
                                        flex: 2,
                                        child: SingleChildScrollView(
                                          child: _buildSummarySection(context, cart, isDark, isDesktop: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: _buildCartList(context, cart, isDark),
                              ),
                              _buildSummarySection(context, cart, isDark, isDesktop: false),
                            ],
                          ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_cart.png', // Assuming we save it here
              width: context.w(280),
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shopping_cart_outlined,
                size: context.sp(100),
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            SizedBox(height: context.h(32)),
            Text(
              'Your cart is empty',
              style: AppTextStyles.font(
                context,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: context.h(12)),
            Text(
              'Looks like you haven\'t added anything yet. Let\'s find something delicious!',
              textAlign: TextAlign.center,
              style: AppTextStyles.font(
                context,
                fontSize: 15,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            SizedBox(height: context.h(40)),
            SizedBox(
              width: double.infinity,
              height: context.h(56),
              child: ElevatedButton(
                onPressed: () async {
                  final loggedIn = await AuthService.isLoggedIn();
                  if (!mounted) return;
                  if (loggedIn) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.home,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.login,
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Ordering',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    Map<String, dynamic> item,
    int index,
    bool isDark,
  ) {
    return Dismissible(
      key: Key(item['name'] + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final removedItem = Map<String, dynamic>.from(item);
        cart.removeItem(index);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: context.h(20)),
        padding: EdgeInsets.symmetric(horizontal: context.w(24)),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: context.sp(28),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.mealDetail,
            arguments: {'meals': cart.items, 'index': index},
          );
        },
        child: Container(
        margin: EdgeInsets.only(bottom: context.h(20)),
        child: Row(
          children: [
            Container(
              width: context.w(100),
              height: context.h(100),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGrey : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(context.w(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(item['image'], fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: AppTextStyles.font(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    item['price'],
                    style: AppTextStyles.font(
                      context,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _quantityBtn(
                  context,
                  Icons.add,
                  () => cart.updateQuantity(index, 1),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: context.h(4)),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(8),
                    vertical: context.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item['quantity']}',
                    style: AppTextStyles.font(
                      context,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _quantityBtn(
                  context,
                  Icons.remove,
                  () => cart.updateQuantity(index, -1),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCartList(BuildContext context, CartProvider cart, bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: context.isDesktop,
      padding: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 0 : context.w(24),
        vertical: context.h(10),
      ),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItem(
          context,
          cart,
          item,
          index,
          isDark,
        );
      },
    );
  }

  Widget _quantityBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: context.sp(18),
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    CartProvider cart,
    bool isDark, {
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(24)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, isDesktop ? 4 : -5),
          ),
        ],
        border: isDesktop ? Border.all(color: Colors.grey.withValues(alpha: 0.1)) : null,
      ),
      child: Column(
        children: [
          TextField(
            controller: _promoController,
            decoration: InputDecoration(
              hintText: 'Do You have any promo code?',
              hintStyle: AppTextStyles.font(
                context,
                fontSize: 14,
                color: Colors.grey,
              ),
              prefixIcon: Icon(
                Icons.percent_rounded,
                color: Colors.grey,
                size: context.sp(20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: AppColors.primaryOrange),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.w(20),
                vertical: context.h(16),
              ),
            ),
          ),
          SizedBox(height: context.h(24)),
          _priceRow(
            context,
            'Subtotal',
            '\$${cart.subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: context.h(8)),
          _priceRow(
            context,
            'Delivery Fee',
            '\$${cart.deliveryFee.toStringAsFixed(2)}',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.h(12)),
            child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          _priceRow(
            context,
            'Total',
            '\$${cart.total.toStringAsFixed(2)}',
            isBold: true,
          ),
          SizedBox(height: context.h(24)),
          SizedBox(
            width: double.infinity,
            height: context.h(60),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.checkout,
                  arguments: {'cartItems': cart.items},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                'Check out',
                style: AppTextStyles.font(
                  context,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(24)),
        ],
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.font(
            context,
            fontSize: 18,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.font(
            context,
            fontSize: 18,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
