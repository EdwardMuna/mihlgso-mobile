import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mihlgso_mobile/main.dart';

void main() {
  testWidgets('App boots to the login screen when signed out', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MihlgsoApp()));
    // Auth check is async (secure storage read); let it settle.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sign in to your account'), findsOneWidget);
  });
}
