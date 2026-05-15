import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

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
          'Weekly Planner',
          style: AppTextStyles.font(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(context.w(24)),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          return _buildDayCard(context, _days[index], isDark);
        },
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, Map<String, dynamic> dayData, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: context.w(4), bottom: context.h(12)),
            child: Text(
              dayData['day'],
              style: AppTextStyles.font(
                context,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: dayData['isToday'] ? AppColors.primaryOrange : null,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGrey : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
              ],
            ),
            child: Column(
              children: [
                _mealEntry(context, 'Breakfast', dayData['breakfast'], Icons.wb_sunny_outlined),
                Divider(height: context.h(24), color: Colors.grey.withValues(alpha: 0.1)),
                _mealEntry(context, 'Lunch', dayData['lunch'], Icons.lunch_dining_outlined),
                Divider(height: context.h(24), color: Colors.grey.withValues(alpha: 0.1)),
                _mealEntry(context, 'Dinner', dayData['dinner'], Icons.nights_stay_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealEntry(BuildContext context, String type, String meal, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.w(8)),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: context.sp(18), color: Colors.grey),
        ),
        SizedBox(width: context.w(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.font(context, fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              Text(meal, style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryOrange, size: context.sp(22)),
        ),
      ],
    );
  }

  static const _days = [
    {
      'day': 'Monday',
      'isToday': true,
      'breakfast': 'Oatmeal with Berries',
      'lunch': 'Classic Beef Burger',
      'dinner': 'Grilled Salmon',
    },
    {
      'day': 'Tuesday',
      'isToday': false,
      'breakfast': 'Avocado Toast',
      'lunch': 'Margherita Pizza',
      'dinner': 'Chicken Stir Fry',
    },
    {
      'day': 'Wednesday',
      'isToday': false,
      'breakfast': 'Pancakes',
      'lunch': 'Caesar Salad',
      'dinner': 'Pasta Carbonara',
    },
  ];
}
