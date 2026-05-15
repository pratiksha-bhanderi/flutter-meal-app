import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Analytics',
          style: AppTextStyles.font(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Mockup
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGrey : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'October 2023',
                    style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: context.sp(20)),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    context,
                    'Total Spent',
                    '\$428.50',
                    Icons.account_balance_wallet_outlined,
                    Colors.blue,
                    isDark,
                  ),
                ),
                SizedBox(width: context.w(16)),
                Expanded(
                  child: _statCard(
                    context,
                    'Avg. Calories',
                    '1,850',
                    Icons.local_fire_department_outlined,
                    Colors.orange,
                    isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(24)),

            // Spending Graph Mockup
            Text(
              'Weekly Spending',
              style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: context.h(16)),
            Container(
              height: context.h(200),
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkGrey : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(context, 0.4, 'W1'),
                  _bar(context, 0.7, 'W2'),
                  _bar(context, 0.5, 'W3'),
                  _bar(context, 0.9, 'W4'),
                ],
              ),
            ),
            SizedBox(height: context.h(32)),

            // Category Breakdown
            Text(
              'Category Breakdown',
              style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: context.h(16)),
            _categoryStat(context, 'Burgers', 0.45, AppColors.primaryOrange),
            _categoryStat(context, 'Pizza', 0.30, Colors.red),
            _categoryStat(context, 'Noodles', 0.15, Colors.green),
            _categoryStat(context, 'Others', 0.10, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: context.sp(20)),
          ),
          SizedBox(height: context.h(12)),
          Text(title, style: AppTextStyles.font(context, fontSize: 12, color: Colors.grey)),
          Text(value, style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: context.w(30),
          height: context.h(140) * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryOrange, AppColors.primaryOrange.withValues(alpha: 0.6)],
            ),
          ),
        ),
        SizedBox(height: context.h(8)),
        Text(label, style: AppTextStyles.font(context, fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _categoryStat(BuildContext context, String label, double percentage, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${(percentage * 100).toInt()}%', style: AppTextStyles.font(context, fontSize: 14, color: Colors.grey)),
            ],
          ),
          SizedBox(height: context.h(8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: context.h(8),
            ),
          ),
        ],
      ),
    );
  }
}
