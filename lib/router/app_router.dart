import 'package:flutter/material.dart';
import 'package:meal_app/core/services/auth_service.dart';
import 'package:meal_app/screens/auth/login_screen.dart';
import 'package:meal_app/screens/auth/register_screen.dart';
import 'package:meal_app/screens/main_screen.dart';
import 'package:meal_app/screens/onboarding/onboarding_screen.dart';
import 'package:meal_app/screens/settings/settings_screen.dart';
import 'package:meal_app/screens/splash/splash_screen.dart';
import 'package:meal_app/screens/home/meal_explorer_screen.dart';
import 'package:meal_app/screens/home/meal_detail_screen.dart';
import 'package:meal_app/screens/home/ingredient_selection_screen.dart';
import 'package:meal_app/screens/home/checkout_screen.dart';
import 'package:meal_app/screens/home/cart_screen.dart';
import 'package:meal_app/screens/home/order_tracking_screen.dart';
import 'package:meal_app/screens/settings/profile_screen.dart';
import 'package:meal_app/screens/settings/order_history_screen.dart';
import 'package:meal_app/screens/settings/addresses_screen.dart';
import 'package:meal_app/screens/settings/payment_methods_screen.dart';
import 'package:meal_app/screens/settings/offers_screen.dart';
import 'package:meal_app/screens/settings/account_details_screen.dart';
import 'package:meal_app/screens/settings/add_address_screen.dart';
import 'package:meal_app/screens/settings/add_payment_method_screen.dart';
import 'package:meal_app/screens/settings/change_password_screen.dart';
import 'package:meal_app/screens/auth/forgot_password_screen.dart';
import 'package:meal_app/screens/auth/email_verification_screen.dart';
import 'package:meal_app/screens/settings/notifications_screen.dart';




import 'package:meal_app/screens/analytics/analytics_screen.dart';
import 'package:meal_app/screens/meal_plan/meal_plan_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String explorer = '/explorer';
  static const String mealDetail = '/mealDetail';
  static const String ingredientSelection = '/ingredientSelection';
  static const String checkout = '/checkout';
  static const String orderTracking = '/orderTracking';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String orderHistory = '/orderHistory';
  static const String addresses = '/addresses';
  static const String paymentMethods = '/paymentMethods';
  static const String offers = '/offers';
  static const String accountDetails = '/accountDetails';
  static const String addAddress = '/addAddress';
  static const String addPaymentMethod = '/addPaymentMethod';
  static const String changePassword = '/changePassword';
  static const String forgotPassword = '/forgotPassword';
  static const String emailVerification = '/emailVerification';
  static const String notifications = '/notifications';




  static const String analytics = '/analytics';
  static const String mealPlan = '/mealPlan';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);
      case login:
        return _slideRoute(const LoginScreen(), settings);
      case register:
        return _slideRoute(const RegisterScreen(), settings);
      case home:
        return _authGuardedRoute(const MainScreen(), settings);
      case AppRouter.settings:
        return _slideRoute(const SettingsScreen(), settings);
      case explorer:
        final category = settings.arguments as String?;
        return _slideRoute(MealExplorerScreen(category: category), settings);
      case mealDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final meals = args['meals'] as List<Map<String, dynamic>>;
        final index = args['index'] as int;
        return _slideRoute(MealDetailScreen(meals: meals, initialIndex: index), settings);
      case ingredientSelection:
        final meal = settings.arguments as Map<String, dynamic>;
        return _fadeRoute(IngredientSelectionScreen(meal: meal), settings);
      case checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('cartItems')) {
          return _slideRoute(CheckoutScreen(cartItems: (args['cartItems'] as List).cast<Map<String, dynamic>>()), settings);
        }
        return _slideRoute(CheckoutScreen(meal: args), settings);
      case orderTracking:
        return _slideRoute(const OrderTrackingScreen(), settings);
      case cart:
        return _slideRoute(const CartScreen(), settings);
      case profile:
        return _slideRoute(const ProfileScreen(), settings);
      case orderHistory:
        return _slideRoute(const OrderHistoryScreen(), settings);
      case addresses:
        return _slideRoute(const AddressesScreen(), settings);
      case paymentMethods:
        return _slideRoute(const PaymentMethodsScreen(), settings);
      case offers:
        return _slideRoute(const OffersScreen(), settings);
      case accountDetails:
        return _slideRoute(const AccountDetailsScreen(), settings);
      case addAddress:
        return _slideRoute(const AddAddressScreen(), settings);
      case addPaymentMethod:
        return _slideRoute(const AddPaymentMethodScreen(), settings);
      case changePassword:
        return _slideRoute(const ChangePasswordScreen(), settings);
      case forgotPassword:
        return _slideRoute(const ForgotPasswordScreen(), settings);
      case emailVerification:
        final email = settings.arguments as String;
        return _slideRoute(EmailVerificationScreen(email: email), settings);
      case notifications:
        return _slideRoute(const NotificationsScreen(), settings);




      case analytics:
        return _slideRoute(const AnalyticsScreen(), settings);
      case mealPlan:
        return _slideRoute(const MealPlanScreen(), settings);
      default:
        return _fadeRoute(const SplashScreen(), settings);
    }
  }

  static Route<dynamic> _authGuardedRoute(
      Widget page, RouteSettings routeSettings) {
    // Simply return the route. The initial auth check is handled in splash/login.
    // Putting a FutureBuilder here causes the entire route to reset on theme rebuilds.
    return _fadeRoute(page, routeSettings);
  }

  static Route<dynamic> _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Clean fade + slight slide up
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        );

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  static Route<dynamic> _slideRoute(Widget page, RouteSettings routeSettings) {
    return PageRouteBuilder(
      settings: routeSettings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(
            position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static Widget _fadeTransition(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
