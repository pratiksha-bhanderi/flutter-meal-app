import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
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
        title: Text('Offers & Promo Codes', style: AppTextStyles.font(context, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(context.w(24)),
        children: [
          _offerCard(context, 'WELCOME50', '50% OFF', 'on your first order', Colors.orange, isDark),
          SizedBox(height: context.h(16)),
          _offerCard(context, 'MEALMATE20', '20% OFF', 'on orders above \$30', Colors.blue, isDark),
          SizedBox(height: context.h(16)),
          _offerCard(context, 'FREEDEL', 'FREE DELIVERY', 'available for today only', Colors.green, isDark),
        ],
      ),
    );
  }

  Widget _offerCard(BuildContext context, String code, String title, String subtitle, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGrey : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(12)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.local_offer_rounded, color: color, size: context.sp(28)),
              ),
              SizedBox(width: context.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                    Text(subtitle, style: AppTextStyles.font(context, fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(code, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                TextButton(
                  onPressed: () => _copyToClipboard(context, code),
                  child: Text('COPY', style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryOrange)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
