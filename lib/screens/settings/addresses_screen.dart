import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';


class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String _selectedLabel = 'Home'; // Default selection

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
        title: Text('My Addresses', style: AppTextStyles.font(context, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: EdgeInsets.all(context.w(24)),
            children: [
              _addressCard(context, 'Home', '123 Gourmet Street, Food City, 56789', Icons.home_rounded, isDark),
              SizedBox(height: context.h(16)),
              _addressCard(context, 'Office', '456 Tech Park, Innovation Way, 10101', Icons.work_rounded, isDark),
              SizedBox(height: context.h(32)),
              _addButton(context, 'Add New Address'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressCard(BuildContext context, String label, String address, IconData icon, bool isDark) {
    final isDefault = _selectedLabel == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLabel = label);
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
                  Row(
                    children: [
                      Text(label, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700)),
                      if (isDefault) ...[
                        SizedBox(width: context.w(8)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(4)),
                          child: Text('DEFAULT', style: AppTextStyles.font(context, fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: context.h(4)),
                  Text(address, style: AppTextStyles.font(context, fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey), 
              onPressed: () => _showMockDialog(context, 'Edit Address'),
            ),
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
        onPressed: () => Navigator.pushNamed(context, AppRouter.addAddress),
        icon: const Icon(Icons.add_rounded, color: AppColors.primaryOrange),
        label: Text(text, style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
      ),
    );
  }
}
