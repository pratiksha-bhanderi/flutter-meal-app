import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Order Delivered! 🍔',
        'body': 'Your order from Bison Burger has been delivered. Enjoy your meal!',
        'time': 'Just now',
        'type': 'order',
        'isRead': false,
      },
      {
        'title': 'Flash Sale Alert! ⚡',
        'body': 'Get 50% OFF on all pizzas for the next 2 hours. Don\'t miss out!',
        'time': '2 hours ago',
        'type': 'deal',
        'isRead': false,
      },
      {
        'title': 'New Promo Code 🎁',
        'body': 'Use code "MEALMATE20" to get 20% off on your next 3 orders.',
        'time': 'Yesterday',
        'type': 'promo',
        'isRead': true,
      },
      {
        'title': 'Rider is arriving 🛵',
        'body': 'Your rider is just 2 minutes away. Get ready to eat!',
        'time': 'Yesterday',
        'type': 'order',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.font(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.w(8)),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isDark)
          : ListView.builder(
              padding: EdgeInsets.all(context.w(24)),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final note = notifications[index];
                return _buildNotificationItem(context, note, isDark);
              },
            ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> note, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    IconData icon;
    Color iconColor;

    switch (note['type']) {
      case 'order':
        icon = Icons.local_shipping_rounded;
        iconColor = Colors.blue;
        break;
      case 'deal':
        icon = Icons.bolt_rounded;
        iconColor = Colors.orange;
        break;
      case 'promo':
        icon = Icons.card_giftcard_rounded;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primaryOrange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: note['isRead'] 
            ? (isDark ? AppColors.darkGrey.withOpacity(0.3) : Colors.white)
            : (isDark ? AppColors.primaryOrange.withOpacity(0.1) : AppColors.primaryOrange.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: note['isRead'] 
              ? Colors.transparent 
              : AppColors.primaryOrange.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(10)),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: context.sp(20)),
          ),
          SizedBox(width: context.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note['title'],
                      style: AppTextStyles.font(
                        context,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (!note['isRead'])
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.h(4)),
                Text(
                  note['body'],
                  style: AppTextStyles.font(
                    context,
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.h(8)),
                Text(
                  note['time'],
                  style: AppTextStyles.font(
                    context,
                    fontSize: 11,
                    color: Colors.grey.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: context.sp(80),
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'No notifications yet',
            style: AppTextStyles.font(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
