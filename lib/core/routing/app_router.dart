import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/store/presentation/store_screen.dart';
import 'app_routes.dart';
import 'boutique_shell.dart';

/// Riverpod provider exposing the app's [GoRouter] instance.
///
/// Kept as a provider (rather than a plain top-level value) so that later
/// phases can add redirects driven by app state (e.g. onboarding not
/// completed yet) without changing how [MaterialApp.router] consumes it.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BoutiqueShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.dashboard, const DashboardScreen()),
          _branch(AppRoutes.store, const StoreScreen()),
          _branch(AppRoutes.products, const ProductsScreen()),
          _branch(AppRoutes.orders, const OrdersScreen()),
          _branch(AppRoutes.profile, const ProfileScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [
      GoRoute(path: path, builder: (context, state) => child),
    ],
  );
}
