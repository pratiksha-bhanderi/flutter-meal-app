import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meal_app/core/services/auth_service.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userEmail;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _faceIdEnabled = true;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await AuthService.getUserEmail();
    if (mounted) setState(() => _userEmail = email);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  Future<void> _pickImage() async {
    try {
      PermissionStatus status = PermissionStatus.granted;
      
      try {
        if (Platform.isAndroid) {
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
        } else {
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
        }
      } catch (e) {
        debugPrint('Permission handler error (plugin might need restart): $e');
        // Fallback: Try to pick image anyway, system might handle it
        status = PermissionStatus.granted;
      }

      if (status.isGranted) {
        final XFile? selected = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (selected != null) {
          setState(() => _imageFile = selected);
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text('Gallery access is needed to change your profile picture. Please enable it in settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
          'Profile',
          style: AppTextStyles.font(
            context,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.w(24)),
        child: Column(
          children: [
            // User Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: context.w(50),
                          backgroundImage: _imageFile != null 
                            ? FileImage(File(_imageFile!.path)) 
                            : const AssetImage('assets/images/onboarding/burger.png') as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: context.sp(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(16)),
                  Text(
                    _userEmail?.split('@').first ?? 'John Doe',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _userEmail ?? 'john.doe@example.com',
                    style: AppTextStyles.font(
                      context,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(40)),

            // Account Sections
            _buildSection(context, 'Account Settings', [
              _profileItem(
                context, 
                Icons.person_outline, 
                'Account', 
                'Name, email, phone',
                onTap: () => Navigator.pushNamed(context, AppRouter.accountDetails),
              ),
              _profileItem(
                context, 
                Icons.location_on_outlined, 
                'Delivery Addresses', 
                'Manage saved addresses',
                onTap: () => Navigator.pushNamed(context, AppRouter.addresses),
              ),
              _profileItem(
                context, 
                Icons.payment_outlined, 
                'Payment Cards', 
                'Manage your cards',
                onTap: () => Navigator.pushNamed(context, AppRouter.paymentMethods),
              ),
              _profileItem(
                context, 
                Icons.local_offer_outlined, 
                'Offers & Promo Codes', 
                'My active coupons',
                onTap: () => Navigator.pushNamed(context, AppRouter.offers),
              ),
            ], isDark),

            SizedBox(height: context.h(24)),
            _buildSection(context, 'Notifications', [
              _switchItem(
                context: context,
                icon: Icons.notifications_none_rounded,
                title: 'Push Notifications',
                subtitle: 'Order status, Offers',
                value: _pushEnabled,
                onChanged: (val) => setState(() => _pushEnabled = val),
              ),
              _switchItem(
                context: context,
                icon: Icons.email_outlined,
                title: 'Email Updates',
                subtitle: 'Receipts, Newsletter',
                value: _emailEnabled,
                onChanged: (val) => setState(() => _emailEnabled = val),
              ),
            ], isDark),

            SizedBox(height: context.h(24)),
            _buildSection(context, 'Security', [
              _profileItem(
                context, 
                Icons.lock_outline_rounded, 
                'Change Password', 
                'Last changed 3 months ago',
                onTap: () => Navigator.pushNamed(context, AppRouter.changePassword),
              ),
              _switchItem(
                context: context,
                icon: Icons.fingerprint_rounded,
                title: 'Face ID / Touch ID',
                subtitle: 'Manage biometric login',
                value: _faceIdEnabled,
                onChanged: (val) => setState(() => _faceIdEnabled = val),
              ),
            ], isDark),
            
            SizedBox(height: context.h(40)),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: context.h(56),
              child: TextButton(
                onPressed: () => _logout(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.h(20)),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.w(4), bottom: context.h(12)),
          child: Text(
            title,
            style: AppTextStyles.font(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGrey : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _profileItem(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(context.w(16)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.w(10)),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryOrange,
                size: context.sp(22),
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.font(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.font(
                      context,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: context.sp(24),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _switchItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.all(context.w(16)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(10)),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryOrange,
              size: context.sp(22),
            ),
          ),
          SizedBox(width: context.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.font(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.font(
                    context,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }
}
