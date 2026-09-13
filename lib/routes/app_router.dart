import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/public/apply_screen.dart';
import '../screens/public/home_screen.dart';
import '../screens/public/about_screen.dart';
import '../screens/public/vision_mission_screen.dart';
import '../screens/public/history_screen.dart';
import '../screens/public/constitution_screen.dart';
import '../screens/public/gallery_screen.dart';
import '../screens/public/leadership_screen.dart';
import '../screens/public/leadership_board_screen.dart';
import '../screens/public/leadership_executive_screen.dart';
import '../screens/public/leadership_departments_screen.dart';
import '../screens/public/membership_screen.dart';
import '../screens/public/membership_status_screen.dart';
import '../screens/public/news_screen.dart';
import '../screens/public/projects_screen.dart';
import '../screens/public/contact_screen.dart';
import '../screens/public/donate_screen.dart';
import '../screens/member/member_shell.dart';
import '../screens/admin/admin_shell.dart';

/// Public marketing routes, reachable without signing in — mirrors the
/// website's public pages. Kept in one list so both the redirect guard and
/// the route table stay in sync.
const publicContentPaths = [
  '/home',
  '/donate',
  '/about',
  '/about/vision-mission',
  '/about/history',
  '/about/constitution',
  '/gallery',
  '/leadership',
  '/leadership/board',
  '/leadership/executive',
  '/leadership/departments',
  '/membership',
  '/membership/status',
  '/news',
  '/projects',
  '/contact',
];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      // Read (not watch) — this provider must not rebuild GoRouter on every
      // auth change, or the router resets to initialLocation and drops the
      // current screen/navigation stack mid-login. refreshListenable is what
      // makes go_router re-run this redirect when auth state changes.
      final authState = ref.read(authControllerProvider);
      final onSplash = state.matchedLocation == '/splash';
      final loggingIn = state.matchedLocation == '/login';
      final onPublicRoute = [
        '/login',
        '/forgot-password',
        '/reset-password',
        '/apply',
        ...publicContentPaths,
      ].contains(state.matchedLocation);

      // Still resolving a persisted session: stay on/go to splash. An
      // in-flight login attempt also sets isLoading, but state.matchedLocation
      // doesn't reliably reflect the current screen when this redirect is
      // re-run via refreshListenable (it can still report the location from
      // before the go() to /login), so check the explicit in-flight flag
      // instead of relying on location matching here.
      if (authState.isLoading) {
        return (onSplash || ref.read(isLoggingInProvider)) ? null : '/splash';
      }

      final user = authState.valueOrNull;

      if (user == null) {
        return onPublicRoute ? null : '/home';
      }
      // Signed in: keep them out of login, route by role.
      if (loggingIn) {
        return user.role == UserRole.admin ? '/admin' : '/member';
      }
      // Cold start with a persisted session: admins land straight on their
      // dashboard; other signed-in users still land on the home screen.
      if (onSplash) {
        return user.role == UserRole.admin ? '/admin' : '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/apply', builder: (context, state) => const ApplyScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/donate', builder: (context, state) => const DonateScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/about/vision-mission', builder: (context, state) => const VisionMissionScreen()),
      GoRoute(path: '/about/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(path: '/about/constitution', builder: (context, state) => const ConstitutionScreen()),
      GoRoute(path: '/gallery', builder: (context, state) => const GalleryScreen()),
      GoRoute(path: '/leadership', builder: (context, state) => const LeadershipScreen()),
      GoRoute(path: '/leadership/board', builder: (context, state) => const LeadershipBoardScreen()),
      GoRoute(path: '/leadership/executive', builder: (context, state) => const LeadershipExecutiveScreen()),
      GoRoute(path: '/leadership/departments', builder: (context, state) => const LeadershipDepartmentsScreen()),
      GoRoute(path: '/membership', builder: (context, state) => const MembershipScreen()),
      GoRoute(path: '/membership/status', builder: (context, state) => const MembershipStatusScreen()),
      GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
      GoRoute(path: '/projects', builder: (context, state) => const ProjectsScreen()),
      GoRoute(path: '/contact', builder: (context, state) => const ContactScreen()),
      GoRoute(path: '/member', builder: (context, state) => const MemberShell()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminShell()),
    ],
  );
});

/// Bridges Riverpod's `AsyncValue<AppUser?>` stream into a Listenable so
/// go_router re-evaluates its redirect whenever auth state changes (login,
/// logout, or a forced logout from a 401).
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
  final Ref _ref;
}
