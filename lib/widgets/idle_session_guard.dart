import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../routes/app_router.dart';

/// How long a signed-in session may sit untouched before being force-logged-out.
const idleLogoutTimeout = Duration(minutes: 10);

/// Wraps the whole app: watches for touch input and, if a signed-in session
/// sits idle past [idleLogoutTimeout], signs the user out and returns them
/// to the login screen. Security requirement for a portal that handles
/// member payment/donation data on potentially shared devices.
class IdleSessionGuard extends ConsumerStatefulWidget {
  const IdleSessionGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<IdleSessionGuard> createState() => _IdleSessionGuardState();
}

class _IdleSessionGuardState extends ConsumerState<IdleSessionGuard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(idleLogoutTimeout, _onIdleTimeout);
  }

  Future<void> _onIdleTimeout() async {
    final isSignedIn = ref.read(authControllerProvider).valueOrNull != null;
    if (!isSignedIn) {
      // Nothing to protect while signed out — keep waiting rather than
      // firing repeatedly.
      _resetTimer();
      return;
    }
    ref.read(sessionExpiredProvider.notifier).state = true;
    await ref.read(authControllerProvider.notifier).logout();
    ref.read(routerProvider).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerSignal: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
