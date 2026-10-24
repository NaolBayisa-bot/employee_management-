import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mobile_app/core/storage/secure_storage.dart';
import 'package:mobile_app/main.dart';

/// In-memory TokenStorage so the widget test never touches the OS keychain
/// (which is unavailable under flutter_test) and so the app starts logged out.
class _FakeStorage extends TokenStorage {
  _FakeStorage() : super(const FlutterSecureStorage());
  String? _token;
  @override
  Future<void> saveToken(String token) async => _token = token;
  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> deleteToken() async => _token = null;
}

void main() {
  testWidgets('App shows Task Manager text and the debug Login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeStorage()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // The old, hardcoded "Test API" placeholder (Task 3) must be gone.
    expect(find.text('Test API'), findsNothing);
    // The temporary debug auth screen is now the home and shows "Login".
    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
