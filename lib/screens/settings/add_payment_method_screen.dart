import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
        }
      });
    }
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
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Payment Method',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Preview
              Container(
                width: double.infinity,
                height: context.h(200),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1a1a1a), Color(0xFF333333)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(context.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.credit_card_rounded, color: Colors.white.withOpacity(0.8), size: context.sp(32)),
                        Text('VISA', style: AppTextStyles.font(context, fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    Text(
                      _numberController.text.isEmpty ? '**** **** **** ****' : _numberController.text,
                      style: AppTextStyles.font(context, fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CARD HOLDER', style: AppTextStyles.font(context, fontSize: 10, color: Colors.white60)),
                            Text(_holderController.text.isEmpty ? 'JOHN DOE' : _holderController.text.toUpperCase(), 
                                style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EXPIRES', style: AppTextStyles.font(context, fontSize: 10, color: Colors.white60)),
                            Text(_expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text, 
                                style: AppTextStyles.font(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(40)),
              _buildFieldLabel(context, 'Card Holder Name'),
              _buildTextField(
                context: context,
                controller: _holderController,
                hint: 'e.g. John Doe',
                icon: Icons.person_outline,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: context.h(20)),
              _buildFieldLabel(context, 'Card Number'),
              _buildTextField(
                context: context,
                controller: _numberController,
                hint: '0000 0000 0000 0000',
                icon: Icons.credit_card_rounded,
                isDark: isDark,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) => value == null || value.length < 16 ? 'Invalid card number' : null,
              ),
              SizedBox(height: context.h(20)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(context, 'Expiry Date'),
                        _buildTextField(
                          context: context,
                          controller: _expiryController,
                          hint: 'MM/YY',
                          icon: Icons.calendar_today_rounded,
                          isDark: isDark,
                          onChanged: (_) => setState(() {}),
                          validator: (value) => value == null || !value.contains('/') ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(context, 'CVV'),
                        _buildTextField(
                          context: context,
                          controller: _cvvController,
                          hint: '000',
                          icon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.length < 3 ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(40)),
              SizedBox(
                width: double.infinity,
                height: context.h(56),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Card',
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
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.font(
          context,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    void Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.font(context, fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryOrange, size: context.sp(20)),
        filled: true,
        fillColor: isDark ? AppColors.darkGrey : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
