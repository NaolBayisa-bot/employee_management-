import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:employee_management/core/storage/secure_storage.dart';
import 'package:employee_management/main.dart';

/// In-memory TokenStorage so the widget test never touches the OS keychain
/// (unavailable under flutter_test) and so the app starts logged out.
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
  testWidgets('App home is the LoginScreen (logged-out form)',
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

    // The old Task 3 placeholder is gone.
    expect(find.text('Test API'), findsNothing);
    // AuthHeader title + the Login button are present.
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
