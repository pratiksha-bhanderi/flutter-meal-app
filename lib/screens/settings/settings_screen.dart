import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:meal_app/core/providers/theme_provider.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  final bool showBackButton;
  const SettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: showBackButton
              ? GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: EdgeInsets.all(context.w(10)),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: context.sp(16),
                      color: cs.onSurface,
                    ),
                  ),
                )
              : null,
          automaticallyImplyLeading: false,
          title: Text(
            'Settings',
            style: AppTextStyles.font(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(context.w(20)),
          children: [
            _sectionLabel(context, 'ACCOUNT', cs),
            SizedBox(height: context.h(10)),
            _card(
              cs: cs,
              child: Column(
                children: [
                  _infoRow(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    label: 'Account',
                    value: 'John Doe',
                    cs: cs,
                    showDivider: true,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.profile),
                  ),
                  _infoRow(
                    context: context,
                    icon: Icons.history_rounded,
                    label: 'Order History',
                    value: '3 orders',
                    cs: cs,
                    showDivider: false,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.orderHistory),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.h(28)),
            _sectionLabel(context, 'APPEARANCE', cs),
            SizedBox(height: context.h(10)),

            // Dark mode toggle
            _card(
              cs: cs,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(4),
                ),
                secondary: Container(
                  width: context.w(40),
                  height: context.h(40),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: cs.primary,
                    size: context.sp(20),
                  ),
                ),
                title: Text(
                  'Dark Mode',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  isDark ? 'Dark theme is on' : 'Light theme is on',
                  style: AppTextStyles.font(
                    context,
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                value: isDark,
                activeTrackColor: cs.primary,
                onChanged: (val) => context.read<ThemeProvider>().setDark(val),
              ),
            ),

            SizedBox(height: context.h(8)),

            // Theme preview
            _card(
              cs: cs,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Colors',
                            style: AppTextStyles.font(
                              context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: context.h(2)),
                          Text(
                            isDark ? 'Dark warm palette' : 'Light warm palette',
                            style: AppTextStyles.font(
                              context,
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _dot(context, cs.primary),
                        SizedBox(width: context.w(6)),
                        _dot(context, cs.secondary),
                        SizedBox(width: context.w(6)),
                        _dot(context, cs.surface, bordered: true),
                        SizedBox(width: context.w(6)),
                        _dot(context, cs.onSurface),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: context.h(28)),
            _sectionLabel(context, 'ABOUT', cs),
            SizedBox(height: context.h(10)),

            _card(
              cs: cs,
              child: Column(
                children: [
                  _infoRow(
                    context: context,
                    icon: Icons.restaurant_menu_rounded,
                    label: 'App',
                    value: 'MealMate',
                    cs: cs,
                    showDivider: true,
                  ),
                  _infoRow(
                    context: context,
                    icon: Icons.tag_rounded,
                    label: 'Version',
                    value: '1.0.0',
                    cs: cs,
                    showDivider: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text, ColorScheme cs) =>
      Text(
        text,
        style: AppTextStyles.font(
          context,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.4),
          letterSpacing: 1.2,
        ),
      );

  Widget _card({required ColorScheme cs, required Widget child}) => Container(
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.outline, width: 1),
    ),
    child: child,
  );

  Widget _dot(BuildContext context, Color color, {bool bordered = false}) =>
      Container(
        width: context.w(22),
        height: context.h(22),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: bordered
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
      );

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
    required bool showDivider,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(16),
              vertical: context.h(14),
            ),
            child: Row(
              children: [
                Container(
                  width: context.w(36),
                  height: context.h(36),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: cs.primary, size: context.sp(18)),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.font(
                      context,
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Text(
                  value,
                  style: AppTextStyles.font(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider) Divider(height: 1, color: cs.outline),
        ],
      ),
    );
  }
}
