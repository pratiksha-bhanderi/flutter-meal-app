import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';


class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'MasterCard'; // Default selection

  void _showMockDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('This feature will be fully integrated with the backend soon!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment Methods', style: AppTextStyles.font(context, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: EdgeInsets.all(context.w(24)),
            children: [
              _cardItem(context, 'MasterCard', '**** **** **** 4589', Icons.credit_card_rounded, isDark),
              SizedBox(height: context.h(16)),
              _cardItem(context, 'Visa Card', '**** **** **** 1234', Icons.credit_card_rounded, isDark),
              SizedBox(height: context.h(16)),
              _walletItem(context, 'Apple Pay', 'Connected', Icons.apple_rounded, isDark),
              SizedBox(height: context.h(32)),
              _addButton(context, 'Add New Payment Method'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardItem(BuildContext context, String brand, String number, IconData icon, bool isDark) {
    final isDefault = _selectedMethod == brand;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = brand);
      },
      child: Container(
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDefault ? AppColors.primaryOrange : Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.w(12)),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: context.sp(24)),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(height: context.h(4)),
                  Text(number, style: AppTextStyles.font(context, fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            if (isDefault) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('DEFAULT', style: AppTextStyles.font(context, fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryOrange)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _walletItem(BuildContext context, String name, String status, IconData icon, bool isDark) {
    final isDefault = _selectedMethod == name;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = name);
      },
      child: Container(
        padding: EdgeInsets.all(context.w(20)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkGrey : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDefault ? AppColors.primaryOrange : Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: context.sp(32), color: isDark ? Colors.white : Colors.black),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(status, style: AppTextStyles.font(context, fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (isDefault)
              const Icon(Icons.check_circle_rounded, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _addButton(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      height: context.h(56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.5), width: 1, style: BorderStyle.solid),
      ),
      child: TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRouter.addPaymentMethod),
        icon: const Icon(Icons.add_rounded, color: AppColors.primaryOrange),
        label: Text(text, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
      ),
    );
  }
}
