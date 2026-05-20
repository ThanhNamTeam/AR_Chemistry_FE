import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../home/providers/theme_provider.dart';
import '../../shared/widgets/portal/portal_shell.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_chemicals_tab.dart';
import '../widgets/admin_combos_tab.dart';
import '../widgets/admin_dashboard_tab.dart';
import '../widgets/admin_reactions_tab.dart';
import '../widgets/admin_top_sales_tab.dart';

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
      context.read<AdminProvider>().initialize();
    });
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    await activatePortal(context, AppPortal.auth);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
      onTabSelected: (i) => setState(() => _index = i),
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
          icon: Icons.local_offer_outlined,
          activeIcon: Icons.local_offer_rounded,
          label: l10n.navCombos,
        ),
      ],
      pages: const [
        AdminDashboardTab(),
        AdminChemicalsTab(),
        AdminReactionsTab(),
        AdminTopSalesTab(),
        AdminCombosTab(),
      ],
    );
  }
}
