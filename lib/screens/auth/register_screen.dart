import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await AuthService.saveToken('mock_token_${_emailController.text}');
    await AuthService.saveUserEmail(_emailController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed(
      AppRouter.emailVerification,
      arguments: _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(24)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: context.h(20)),

                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: context.w(44),
                              height: context.w(44),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: cs.outline, width: 1),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: context.sp(18),
                                color: cs.onSurface,
                              ),
                            ),
                          ),

                          SizedBox(height: context.h(24)),

                          // Logo
                          Center(
                            child: Container(
                              width: context.w(80),
                              height: context.w(80),
                              constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
                                ),
                                borderRadius: BorderRadius.circular(context.w(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                color: Colors.white,
                                size: context.sp(40),
                              ),
                            ),
                          ),

                          SizedBox(height: context.h(36)),

                          Text(
                            'Create Account 🍽️',
                            style: AppTextStyles.font(context, 
                              fontSize: context.sp(30),
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: context.h(6)),
                          Text(
                            'Join us and discover amazing meals',
                            style: AppTextStyles.font(context, 
                                fontSize: context.sp(14),
                                color: cs.onSurface.withValues(alpha: 0.55)),
                          ),

                      SizedBox(height: context.h(36)),

                      _label(context, 'Full Name', cs),
                      SizedBox(height: context.h(8)),
                      _field(
                        context: context,
                        cs: cs,
                        controller: _nameController,
                        hint: 'John Doe',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),
                      SizedBox(height: context.h(20)),

                      _label(context, 'Email', cs),
                      SizedBox(height: context.h(8)),
                      _field(
                        context: context,
                        cs: cs,
                        controller: _emailController,
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),

                      _label(context, 'Password', cs),
                      SizedBox(height: context.h(8)),
                      _field(
                        context: context,
                        cs: cs,
                        controller: _passwordController,
                        hint: 'Min. 6 characters',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: _eyeButton(
                          context: context,
                          visible: _obscurePassword,
                          cs: cs,
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: context.h(20)),

                      _label(context, 'Confirm Password', cs),
                      SizedBox(height: context.h(8)),
                      _field(
                        context: context,
                        cs: cs,
                        controller: _confirmPasswordController,
                        hint: 'Repeat your password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirm,
                        suffixIcon: _eyeButton(
                          context: context,
                          visible: _obscureConfirm,
                          cs: cs,
                          onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.h(36)),

                      SizedBox(
                        width: double.infinity,
                        height: context.h(56),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            disabledBackgroundColor:
                                cs.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: context.w(22),
                                  height: context.h(22),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: AppTextStyles.font(context, 
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),

                      SizedBox(height: context.h(24)),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.font(context, 
                                color: cs.onSurface.withValues(alpha: 0.55),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                'Sign In',
                                style: AppTextStyles.font(context, 
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.h(40)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text, ColorScheme cs) => Text(
        text,
        style: AppTextStyles.font(context, 
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      );

  Widget _eyeButton({
    required BuildContext context,
    required bool visible,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) =>
      IconButton(
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: cs.onSurface.withValues(alpha: 0.4),
          size: context.sp(20),
        ),
        onPressed: onTap,
      );

  Widget _field({
    required BuildContext context,
    required ColorScheme cs,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.font(context, fontSize: 14, color: cs.onSurface),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.font(context, 
            color: cs.onSurface.withValues(alpha: 0.35), fontSize: 14),
        prefixIcon: Icon(icon,
            color: cs.onSurface.withValues(alpha: 0.4), size: context.sp(20)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: cs.surface,
        contentPadding:
            EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(16)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
