import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/utils/responsive_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await AuthService.saveToken('mock_token_${_emailController.text}');
    await AuthService.saveUserEmail(_emailController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
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
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.075),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Logo icon
                      Center(
                        child: Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.1,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.045),

                      Text(
                        'Welcome Back 😋',
                        style: AppTextStyles.font(context, 
                          fontSize: screenWidth * 0.075,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: context.h(6)),
                      Text(
                        'Sign in to continue your delicious journey',
                        style: AppTextStyles.font(context, 
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: 0.55)),
                      ),

                      SizedBox(height: context.h(40)),

                      _buildLabel(context, 'Email', cs),
                      SizedBox(height: context.h(8)),
                      _buildTextField(
                        context: context,
                        cs: cs,
                        controller: _emailController,
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.h(20)),

                      _buildLabel(context, 'Password', cs),
                      SizedBox(height: context.h(8)),
                      _buildTextField(
                        context: context,
                        cs: cs,
                        controller: _passwordController,
                        hint: 'Your password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: cs.onSurface.withValues(alpha: 0.45),
                            size: context.sp(20),
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (val.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: context.h(8)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRouter.forgotPassword),
                          child: Text(
                            'Forgot password?',
                            style: AppTextStyles.font(context, 
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: context.h(20)),

                      SizedBox(
                        width: double.infinity,
                        height: context.h(56),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            disabledBackgroundColor:
                                cs.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: context.w(22),
                                  height: context.h(22),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: AppTextStyles.font(context, 
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),

                      SizedBox(height: context.h(28)),

                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: cs.outline, height: 1)),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: context.w(12)),
                            child: Text(
                              'or',
                              style: AppTextStyles.font(context, 
                                color: cs.onSurface.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: cs.outline, height: 1)),
                        ],
                      ),

                      SizedBox(height: context.h(28)),

                      Center(
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppTextStyles.font(context, 
                                    color: cs.onSurface.withValues(alpha: 0.55),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppRouter.register),
                                  child: Text(
                                    'Sign Up',
                                    style: AppTextStyles.font(context, 
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.h(16)),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRouter.onboarding),
                              child: Text(
                                'First time? View Onboarding',
                                style: AppTextStyles.font(context, 
                                  color: cs.primary.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
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
    );
  }

  Widget _buildLabel(BuildContext context, String text, ColorScheme cs) => Text(
        text,
        style: AppTextStyles.font(context, 
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      );

  Widget _buildTextField({
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
      style:
          AppTextStyles.font(context, fontSize: 14, color: cs.onSurface),
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
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1),
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
