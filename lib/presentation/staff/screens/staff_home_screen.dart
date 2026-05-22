import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/app_portal.dart';
import '../../../routes/app_routes.dart';
import '../../auth/providers/role_session_provider.dart';
import '../../../core/portal/portal_scope.dart';
import '../../home/providers/theme_provider.dart';
import '../../shared/widgets/portal/portal_shell.dart';
import '../providers/staff_provider.dart';
import '../widgets/staff_dashboard_tab.dart';
import '../widgets/staff_feedback_tab.dart';
import '../widgets/staff_quiz_tab.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activatePortal(context, AppPortal.staff);
      context.read<StaffProvider>().initialize();
    });
  }

  Future<void> _logout() async {
    await context.read<RoleSessionProvider>().logout();
    final session = await Amplify.Auth.fetchAuthSession();

    debugPrint(session.isSignedIn.toString());
    await activatePortal(context, AppPortal.auth);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final staff = context.watch<StaffProvider>();
    final email = context.watch<RoleSessionProvider>().email ?? 'staff';

    return PortalShell(
      portalTitle: l10n.staffPortal,
      roleBadge: l10n.roleStaff,
      userEmail: email,
      selectedIndex: _index,
      onTabSelected: (i) => setState(() => _index = i),
      isLoading: staff.isLoading,
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
          icon: Icons.feedback_outlined,
          activeIcon: Icons.feedback_rounded,
          label: l10n.feedback,
        ),
        PortalNavItem(
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
          label: l10n.quizPipeline,
        ),
      ],
      pages: [
        StaffDashboardTab(
          onOpenFeedback: () => setState(() => _index = 1),
          onOpenQuiz: () => setState(() => _index = 2),
        ),
        const StaffFeedbackTab(),
        const StaffQuizTab(),
      ],
    );
  }
}
