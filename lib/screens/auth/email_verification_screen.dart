import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isResending = false);
      // We removed SnackBars, so maybe just a small visual feedback or just silence as requested.
      // But for "Resend", usually some feedback is good. 
      // However, the user asked to remove SnackBars if they don't work with timer.
      // I'll stick to no snackbar for now or maybe a simple text update.
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.w(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Illustration or Icon
              Container(
                padding: EdgeInsets.all(context.w(32)),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: context.sp(80),
                  color: cs.primary,
                ),
              ),
              SizedBox(height: context.h(40)),
              Text(
                'Verify Your Email 📧',
                textAlign: TextAlign.center,
                style: AppTextStyles.font(context, 
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: context.h(16)),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.font(context, 
                    fontSize: 15,
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We\'ve sent a verification link to\n'),
                    TextSpan(
                      text: widget.email,
                      style: AppTextStyles.font(context, 
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const TextSpan(text: '.\nPlease check your inbox and click the link to continue.'),
                  ],
                ),
              ),
              const Spacer(),
              // Resend Button
              TextButton(
                onPressed: _isResending ? null : _resendEmail,
                child: _isResending 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                    )
                  : Text(
                      'Didn\'t receive the email? Resend',
                      style: AppTextStyles.font(context, 
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
              ),
              SizedBox(height: context.h(16)),
              // Continue Button (Simulating that user verified)
              SizedBox(
                width: double.infinity,
                height: context.h(56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRouter.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'I\'ve Verified My Email',
                    style: AppTextStyles.font(context, 
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(12)),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRouter.login),
                child: Text(
                  'Back to Login',
                  style: AppTextStyles.font(context, 
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
