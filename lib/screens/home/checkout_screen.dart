import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/order_provider.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? meal;
  final List<Map<String, dynamic>>? cartItems;

  const CheckoutScreen({super.key, this.meal, this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use passed meal, passed cartItems, or fallback to mock
    final List<Map<String, dynamic>> items = widget.meal != null 
        ? [widget.meal!] 
        : (widget.cartItems ?? _mockItems);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: _buildAppBar(context, isDark),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Order Summary'),
              _buildOrderList(context, items, isDark),
              
              _buildSectionTitle(context, 'Delivery Address'),
              _buildAddressCard(context, isDark),
              
              _buildSectionTitle(context, 'Payment Method'),
              _buildPaymentCard(context, isDark),
              
              _buildPriceBreakdown(context, items, isDark),
              
              SizedBox(height: context.h(40)),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context, items),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : Colors.black,
          size: context.sp(20),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Checkout',
        style: AppTextStyles.font(
          context,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(24), context.h(24), context.w(24), context.h(12)),
      child: Text(
        title,
        style: AppTextStyles.font(
          context,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<Map<String, dynamic>> items, bool isDark) {
    return SizedBox(
      height: context.h(120),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.w(24)),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRouter.mealDetail,
                arguments: {
                  'meals': items,
                  'index': index,
                },
              );
            },
            child: Container(
              width: context.w(280),
              margin: EdgeInsets.only(right: context.w(16)),
              padding: EdgeInsets.all(context.w(12)),
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
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item['image']!,
                      width: context.w(80),
                      height: context.h(80),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: context.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['name']!,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          item['category'] ?? 'Main Course',
                          style: AppTextStyles.font(
                            context,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: context.h(8)),
                        Text(
                          item['price'] ?? '\$12.99',
                          style: AppTextStyles.font(
                            context,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryOrange,
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
    );
  }

  Widget _buildAddressCard(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Container(
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.w(12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange,
                    AppColors.secondaryOrange,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: context.sp(22),
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    '123 Gourmet Street, Food City, 56789',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(context.w(6)),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: context.sp(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(24)),
      child: Container(
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        border: Border.all(
          color: AppColors.blueAccent.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.blueAccent,
                  Color(0xFF64B5F6),
                ],
              ),
              shape: BoxShape.circle,
            ),
              child: Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: context.sp(22),
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    'MasterCard **** 4589',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(context.w(6)),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: context.sp(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, List<Map<String, dynamic>> items, bool isDark) {
    // Basic calculation logic
    double subtotal = 0;
    for (var item in items) {
      final priceStr = item['price']?.replaceAll('\$', '') ?? '0';
      subtotal += double.tryParse(priceStr) ?? 0;
    }
    const deliveryFee = 2.50;
    final total = subtotal + deliveryFee;

    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(24), context.h(32), context.w(24), 0),
      child: Column(
        children: [
          _buildPriceRow(
            context,
            'Total Amount',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.font(
            context,
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? null : Colors.grey,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.font(
            context,
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            color: isTotal ? AppColors.primaryOrange : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, List<Map<String, dynamic>> items) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.w(24),
        context.h(12),
        context.w(24),
        context.h(12) + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.h(56),
        child: ElevatedButton(
          onPressed: () {
            _handlePlaceOrder(context, items);
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
            'Place Order',
            style: AppTextStyles.font(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handlePlaceOrder(BuildContext context, List<Map<String, dynamic>> items) async {
    // Calculate total
    double subtotal = 0;
    for (var item in items) {
      final priceStr = item['price']?.replaceAll('\$', '') ?? '0';
      subtotal += (double.tryParse(priceStr) ?? 0) * (item['quantity'] ?? 1);
    }
    final total = subtotal + 2.50;

    // Save to order history
    await context.read<OrderProvider>().placeOrder(items, total);

    // Clear cart if we ordered the full cart
    if (widget.meal == null) {
      context.read<CartProvider>().clearCart();
    }

    if (mounted) {
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: context.h(20)),
            Container(
              padding: EdgeInsets.all(context.w(20)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: context.sp(60),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text(
              'Order Placed!',
              style: AppTextStyles.font(
                context,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: context.h(12)),
            Text(
              'Your delicious meal is on the way.',
              textAlign: TextAlign.center,
              style: AppTextStyles.font(
                context,
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: context.h(32)),
            SizedBox(
              width: double.infinity,
              height: context.h(50),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, AppRouter.orderTracking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Track Order',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.h(12)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRouter.home,
                  (route) => false,
                );
              },
              child: Text(
                'Back to Home',
                style: AppTextStyles.font(
                  context,
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _mockItems = [
    {
      'name': 'Classic Beef Burger',
      'price': '\$12.99',
      'image': 'assets/images/meals/burger.png',
      'category': 'Burgers',
    },
    {
      'name': 'Crispy French Fries',
      'price': '\$4.50',
      'image': 'assets/images/meals/all.png', // Placeholder
      'category': 'Sides',
    },
  ];
}
