import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../shared/widgets/portal/portal_shell.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_cards_tab.dart';
import '../widgets/admin_chemicals_tab.dart';
import '../widgets/admin_dashboard_tab.dart';
import '../widgets/admin_kits_tab.dart';
import '../widgets/admin_logs_tab.dart';
import '../widgets/admin_reactions_tab.dart';
import '../widgets/admin_top_sales_tab.dart';
import '../widgets/admin_users_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      activatePortal(context, AppPortal.admin);
    });
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    final session = await Amplify.Auth.fetchAuthSession();

    debugPrint(session.isSignedIn.toString());
    if (!mounted) return;
    await activatePortal(context, AppPortal.auth);
    if (!mounted) return;
    unawaited(Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = context.watch<RoleSessionProvider>().email ?? 'admin';

    return PortalShell(
      portalTitle: l10n.adminPortal,
      roleBadge: l10n.roleAdmin,
      userEmail: email,
      selectedIndex: _index,
      onTabSelected: (i) {
        setState(() => _index = i);

        if (i == 1) {
          context.read<AdminProvider>().loadSubstances();
        }

        if (i == 2) {
          context.read<AdminProvider>().loadKits();
        }

        if (i == 5) {
          context.read<AdminProvider>().loadChemicalCards();
        }
      },
      onProfile: () =>
          Navigator.pushNamed(context, AppRoutes.portalProfile),
      onLogout: _logout,
      navItems: [
        PortalNavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: l10n.navOverview,
        ),
        PortalNavItem(
          icon: Icons.science_outlined,
          activeIcon: Icons.science_rounded,
          label: l10n.navChemicals,
        ),
        PortalNavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: l10n.navKits,
        ),
        PortalNavItem(
          icon: Icons.biotech_outlined,
          activeIcon: Icons.biotech_rounded,
          label: l10n.navReactions,
        ),
        PortalNavItem(
          icon: Icons.trending_up,
          activeIcon: Icons.trending_up_rounded,
          label: l10n.navTopSales,
        ),
        PortalNavItem(
          icon: Icons.style_outlined,
          activeIcon: Icons.style_rounded,
          label: l10n.navCardsAr,
        ),
        PortalNavItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people_rounded,
          label: l10n.navUsers,
        ),
        PortalNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: l10n.navLogs,
        ),
      ],
      pages: const [
        AdminDashboardTab(),
        AdminChemicalsTab(),
        AdminKitsTab(),
        AdminReactionsTab(),
        AdminTopSalesTab(),
        AdminCardsTab(),
        AdminUsersTab(),
        AdminLogsTab(),
      ],
    );
  }
}
