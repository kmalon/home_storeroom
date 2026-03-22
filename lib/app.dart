import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product_list/product_list_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/product_names/product_names_screen.dart';
import 'screens/add_product/add_product_screen.dart';
import 'screens/remove_product/remove_product_screen.dart';
import 'screens/config/config_screen.dart';
import 'screens/fridge/fridge_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final isLoggedIn = auth.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/products';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/products',
            builder: (_, __) => const ProductListScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (_, __) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/product-names',
            builder: (_, __) => const ProductNamesScreen(),
          ),
          GoRoute(
            path: '/fridge',
            builder: (_, __) => const FridgeScreen(),
          ),
          GoRoute(
            path: '/config',
            builder: (_, __) => const ConfigScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/add-product',
        builder: (_, __) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/remove-product',
        builder: (_, __) => const RemoveProductScreen(),
      ),
    ],
    initialLocation: '/login',
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Home Storeroom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
