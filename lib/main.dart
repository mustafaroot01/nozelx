import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/utils/responsive.dart';
import 'core/services/live_update_service.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/user_stats_service.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/pages/otp_auth_screen.dart';
import 'screens/auth/phone_screen.dart';

import 'features/cart/presentation/providers/cart_manager.dart';
import 'providers/cart_provider.dart';
import 'providers/product_tags_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'features/home/presentation/pages/home_screen.dart';
import 'features/products/presentation/pages/products_list_screen.dart';
import 'features/products/presentation/pages/product_details_screen.dart';
import 'features/cart/presentation/pages/cart_screen.dart';
import 'features/checkout/presentation/pages/checkout_screen.dart';
import 'features/checkout/presentation/pages/order_success_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'features/profile/presentation/pages/edit_profile_screen.dart';
import 'features/profile/presentation/pages/notifications_screen.dart';
import 'features/profile/presentation/pages/my_vehicles_screen.dart';
import 'features/categories/presentation/pages/categories_screen.dart';
import 'features/orders/presentation/pages/orders_list_screen.dart';
import 'features/orders/presentation/pages/order_details_screen.dart';

// New Screens
import 'features/favorites/presentation/pages/favorites_screen.dart';
import 'features/coupons/presentation/pages/coupons_screen.dart';
import 'features/addresses/presentation/pages/addresses_screen.dart';
import 'features/payment/presentation/pages/payment_methods_screen.dart';

import 'features/ai_assistant/presentation/pages/ai_assistant_screen.dart';
import 'features/help/presentation/pages/help_screen.dart';
import 'features/about/presentation/pages/about_screen.dart';
import 'features/recently_viewed/presentation/pages/recently_viewed_screen.dart';
import 'features/orders/presentation/pages/order_tracking_screen.dart';

// Services Feature
import 'screens/services/services_screen.dart';
import 'features/services/presentation/pages/my_bookings_screen.dart';

// Splash Screen
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Supabase imports removed as they were unused

import 'features/favorites/presentation/providers/favorites_provider.dart';
import 'features/addresses/presentation/providers/address_provider.dart';
import 'providers/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize Firebase (optional - will work if google-services.json exists)
  // This is handled gracefully to allow running on simulator without Firebase config
  try {
    // Check if we're on a platform that has Firebase config
    // For simulator, we skip Firebase initialization
    if (Platform.isIOS || Platform.isAndroid) {
      // Try to initialize, but don't fail if it doesn't work
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase - app will work for development/testing
  }

  // Initialize Supabase ✅
  try {
    if (await File('.env').exists()) {
      await dotenv.load(fileName: '.env');
    }
  } catch (e) {
    debugPrint('Environment file (.env) not found, skipping: $e');
  }
  // Supabase commented out - PHP backend primary
  /*
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await SupabaseService.instance.init();
  */

  // Initialize Notification Service
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification service initialization failed: $e');
  }

  // Initialize user stats service
  try {
    await UserStatsService.initialize();
  } catch (e) {
    debugPrint('User stats service initialization failed: $e');
  }

  // Start real-time stock WebSocket listener
  try {
    LiveUpdateService().startListening();
  } catch (e) {
    debugPrint('LiveUpdateService failed to start: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..initialize()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()..fetchSettings()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartManager()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()..init()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ProductTagsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نوزل',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeController>().getThemeMode(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Responsive.init(context);
        return child!;
      },
      home: const _AppStartup(),
      routes: {
        '/login': (context) => const PhoneScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ProductsListScreen(
            categoryFilter: args?['categoryFilter']?.toString(),
            categoryId: args?['categoryId']?.toString(),
            companyFilter: args?['companyFilter']?.toString(),
            viscosityFilter: args?['viscosityFilter']?.toString(),
            searchFilter: args?['searchFilter']?.toString(),
            autoFocusSearch: args?['autoFocusSearch'] as bool? ?? false,
            brandId: args?['brandId']?.toString(),
            brandName: args?['brandName']?.toString(),
          );
        },
        '/product': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final productId = args?['productId']?.toString() ?? '1';
          return ProductDetailsScreen(productId: productId);
        },
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-success': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final orderNumber = args?['orderNumber']?.toString() ?? '';
          final totalAmount = double.tryParse(args?['totalAmount']?.toString() ?? '0') ?? 0.0;
          return OrderSuccessScreen(orderNumber: orderNumber, totalAmount: totalAmount);
        },
        '/order-details': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final orderId = args?['orderId']?.toString() ?? '';
          return OrderDetailsScreen(orderId: orderId);
        },
        '/profile': (context) => const ProfileScreen(),
        '/account': (context) => const ProfileScreen(),
        '/my-vehicles': (context) => const MyVehiclesScreen(),
        '/settings': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/my-orders': (context) => const OrdersListScreen(),
        '/my-service-requests': (context) => const MyBookingsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/coupons': (context) => const CouponsScreen(),
        '/addresses': (context) => const AddressesScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/recently-viewed': (context) => const RecentlyViewedScreen(),

        '/ai-assistant': (context) => const AIAssistantScreen(),
        '/help': (context) => const HelpScreen(),
        '/about': (context) => const AboutScreen(),
        '/order-tracking': (context) => const OrderTrackingScreen(),
        '/orders': (context) => const OrdersListScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/services': (context) => const ServicesScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}

class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.initialize();

    if (auth.isLoggedIn) {
      // حمّل بيانات المستخدم معاً
      await Future.wait([
        context.read<CartProvider>().fetchCart(),
        context.read<FavoritesProvider>().fetchFavorites(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.initialized) {
          return const _SplashScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

