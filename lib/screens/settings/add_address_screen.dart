import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isLoading = false;
  String _selectedType = 'Home';

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Mock save delay
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
          'Add New Address',
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
              _buildFieldLabel(context, 'Address Label'),
              _buildTextField(
                context: context,
                controller: _labelController,
                hint: 'e.g. My Apartment, Mom\'s House',
                icon: Icons.label_outline_rounded,
                isDark: isDark,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a label' : null,
              ),
              SizedBox(height: context.h(20)),
              _buildFieldLabel(context, 'Full Address'),
              _buildTextField(
                context: context,
                controller: _addressController,
                hint: 'Street name, House number',
                icon: Icons.location_on_outlined,
                isDark: isDark,
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
              ),
              SizedBox(height: context.h(20)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(context, 'City'),
                        _buildTextField(
                          context: context,
                          controller: _cityController,
                          hint: 'Food City',
                          icon: Icons.location_city_rounded,
                          isDark: isDark,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(context, 'Zip Code'),
                        _buildTextField(
                          context: context,
                          controller: _zipController,
                          hint: '12345',
                          icon: Icons.pin_drop_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(32)),
              _buildFieldLabel(context, 'Address Type'),
              Row(
                children: [
                  _typeChip('Home', Icons.home_rounded),
                  SizedBox(width: context.w(12)),
                  _typeChip('Office', Icons.work_rounded),
                  SizedBox(width: context.w(12)),
                  _typeChip('Other', Icons.place_rounded),
                ],
              ),
              SizedBox(height: context.h(40)),
              SizedBox(
                width: double.infinity,
                height: context.h(56),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
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
                        'Save Address',
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

  Widget _typeChip(String label, IconData icon) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(10)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.sp(16), color: isSelected ? Colors.white : Colors.grey),
            SizedBox(width: context.w(8)),
            Text(
              label,
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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
