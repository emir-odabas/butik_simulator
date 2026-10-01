import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/components/index_tab_bar.dart';
import '../design/components/ledger_page.dart';

/// The persistent bottom-navigation shell around the app's 5 main tabs.
///
/// Wraps [StatefulShellRoute.indexedStack] so each tab keeps its own
/// navigation stack and scroll position when switching between tabs.
/// The navigation chrome itself is the Atelier Ledger [IndexTabBar] on
/// a paper-grain [LedgerPage] surface, rather than a Material
/// `NavigationBar` — this is the one piece of chrome visible on every
/// single screen, so it's where Faz A proves the design system out.
class BoutiqueShell extends StatelessWidget {
  const BoutiqueShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: SafeArea(
        top: false,
        child: LedgerPage(
          child: IndexTabBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              // Tapping the already-active tab pops it back to its root.
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        ),
      ),
    );
  }
}
