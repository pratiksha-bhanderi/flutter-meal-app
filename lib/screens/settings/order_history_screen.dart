import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/core/providers/order_provider.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.pastOrders;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: context.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order History',
          style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? _buildEmptyState(context, cs)
          : ListView.builder(
              padding: EdgeInsets.all(context.w(20)),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order, cs);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(24)),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: context.sp(64), color: cs.primary),
          ),
          SizedBox(height: context.h(24)),
          Text(
            'No orders yet',
            style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: context.h(8)),
          Text(
            'Your past orders will appear here',
            style: AppTextStyles.font(context, fontSize: 14, color: cs.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order, ColorScheme cs) {
    final date = DateTime.parse(order['date']);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    final items = order['items'] as List;
    final total = order['total'] as double;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order['id'].toString().substring(order['id'].toString().length - 6)}',
                    style: AppTextStyles.font(context, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    formattedDate,
                    style: AppTextStyles.font(context, fontSize: 12, color: cs.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'] ?? 'Delivered',
                  style: AppTextStyles.font(context, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                ),
              ),
            ],
          ),
          Divider(height: context.h(24), color: cs.outline),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: context.h(8)),
            child: Row(
              children: [
                Text(
                  '${item['quantity']}x ',
                  style: AppTextStyles.font(context, fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary),
                ),
                Expanded(
                  child: Text(
                    item['name'],
                    style: AppTextStyles.font(context, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  item['price'],
                  style: AppTextStyles.font(context, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          Divider(height: context.h(24), color: cs.outline),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.font(context, fontSize: 12, color: cs.onSurface.withOpacity(0.5)),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _reorderItems(context, items),
                icon: Icon(Icons.reorder_rounded, size: context.sp(16)),
                label: Text('Reorder', style: AppTextStyles.font(context, fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(10)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reorderItems(BuildContext context, List items) {
    final cart = context.read<CartProvider>();
    for (var item in items) {
      // Re-add each item to the cart
      // Assuming item structure matches what CartProvider expects
      for (int i = 0; i < (item['quantity'] as int); i++) {
        cart.addToCart(Map<String, dynamic>.from(item));
      }
    }
    
    // No snackbar as requested
  }
}
