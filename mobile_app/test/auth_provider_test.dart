// Unit + widget tests for Task 4's auth layer (AuthRepository + authProvider).
//
// AuthRepository is exercised directly with a fake ApiClient + in-memory token
// storage. authProvider (AsyncNotifier) is exercised through ProviderContainer
// overrides that swap in the same fakes, so no real network / secure-storage
// platform calls occur.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:employee_management/core/network/api_client.dart';
import 'package:employee_management/core/network/api_exception.dart';
import 'package:employee_management/core/router/app_router.dart';
import 'package:employee_management/core/storage/secure_storage.dart';
import 'package:employee_management/features/auth/data/auth_repository.dart';
import 'package:employee_management/features/auth/providers/auth_provider.dart';
import 'package:employee_management/features/auth/screens/deactivated_screen.dart';
import 'package:employee_management/features/auth/screens/home_screen.dart';
import 'package:employee_management/features/auth/screens/login_screen.dart';
import 'package:employee_management/features/auth/screens/waiting_approval_screen.dart';
import 'package:employee_management/core/theme/app_theme.dart';
import 'package:employee_management/shared/widgets/app_background.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Helpers: JWT tokens + fakes
// ---------------------------------------------------------------------------

String _b64(Map<String, dynamic> m) =>
    base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');

/// Builds an unsigned JWT whose payload is [payload]. `jwt_decoder` only reads
/// the `exp` claim (it does not verify signatures when no secret is supplied),
/// so a dummy signature is fine for expiry tests.
String _jwt(Map<String, dynamic> payload) =>
    '${_b64({"alg": "HS256", "typ": "JWT"})}.${_b64(payload)}.sig';

String _validToken() => _jwt({
      'id': 'u1',
      'exp': (DateTime.now().add(const Duration(days: 1))).millisecondsSinceEpoch ~/ 1000,
    });

String _expiredToken() => _jwt({
      'id': 'u1',
      'exp': (DateTime.now().subtract(const Duration(days: 1))).millisecondsSinceEpoch ~/ 1000,
    });

const _adminUserJson = <String, dynamic>{
  'id': 'u1',
  'name': 'Admin One',
  'email': 'admin@example.com',
  'role': 'ADMIN',
  'status': 'ACTIVE',
  'createdAt': '2024-01-01T00:00:00.000Z',
};

/// In-memory TokenStorage that never touches the OS keychain.
class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage() : super(const FlutterSecureStorage());
  String? _token;
  String? get token => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> deleteToken() async => _token = null;
}

class _Entry {
  _Entry(this.data, this.error, this.statusCode);
  final dynamic data;
  final ApiException? error;
  final int? statusCode;
}

/// ApiClient whose get/post return canned JSON or errors keyed by "METHOD path".
class FakeApiClient extends ApiClient {
  FakeApiClient() : super(Dio());

  final Map<String, _Entry> _responses = {};
  final List<String> _calls = [];

  void setJson(String methodPath, Map<String, dynamic> data, [int code = 200]) {
    _responses[methodPath] = _Entry(data, null, code);
  }

  void setError(String methodPath, ApiException error) {
    _responses[methodPath] = _Entry(null, error, null);
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _calls.add('POST $path');
    final e = _responses['POST $path'];
    if (e == null) {
      throw ApiException(message: 'no fake for POST $path');
    }
    if (e.error != null) {
      throw e.error!;
    }
    return Future.value(Response<T>(
      data: e.data,
      statusCode: e.statusCode,
      requestOptions: RequestOptions(path: path),
    ));
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _calls.add('GET $path');
    final e = _responses['GET $path'];
    if (e == null) {
      throw ApiException(message: 'no fake for GET $path');
    }
    if (e.error != null) {
      throw e.error!;
    }
    return Future.value(Response<T>(
      data: e.data,
      statusCode: e.statusCode,
      requestOptions: RequestOptions(path: path),
    ));
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _calls.add('DELETE $path');
    return Future.value(Response<T>(
      data: null,
      statusCode: 204,
      requestOptions: RequestOptions(path: path),
    ));
  }
}

/// Shared fakes reused by both the repository-direct and container tests.
class _Fixtures {
  final api = FakeApiClient();
  final storage = FakeTokenStorage();

  void meOk() => api.setJson('GET /auth/me', {'user': Map<String, dynamic>.from(_adminUserJson)});
  void meError(ApiException e) => api.setError('GET /auth/me', e);
  void loginOk(String token) => api.setJson('POST /auth/login', <String, dynamic>{
        'token': token,
        'user': Map<String, dynamic>.from(_adminUserJson),
      });
  void loginError(ApiException e) => api.setError('POST /auth/login', e);
  void registerOk() => api.setJson('POST /auth/register', <String, dynamic>{
        'message': 'User registered successfully',
        'user': Map<String, dynamic>.from(<String, dynamic>{
          'id': 'u2',
          'name': 'Reg Person',
          'email': 'reg@example.com',
          'role': null,
          'status': 'PENDING',
        }),
      });
}

/// Shorthand to override the storage + api client providers used by auth.
List<Override> _o(_Fixtures f) => [
      tokenStorageProvider.overrideWithValue(f.storage),
      apiClientProvider.overrideWithValue(f.api),
    ];

// ---------------------------------------------------------------------------

/// Wrap [child] in a themed [MaterialApp] (dark glassmorphism theme + ambient
/// background) under a [ProviderScope] with the given auth overrides.
Widget _wrap(Widget child, [List<Override>? overrides]) => ProviderScope(
      overrides: overrides ?? const [],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        builder: (context, child) => AppBackground(child: child!),
        home: child,
      ),
    );

/// Wrap [child] in a themed [MaterialApp.router] with a test router,
/// under a [ProviderScope] with the given auth overrides.
/// This is used for tests that need go_router navigation.
Widget _wrapWithRouter(Widget child, [List<Override>? overrides]) {
  // Create a notifier to trigger router refresh when auth state changes
  final refreshNotifier = ValueNotifier<int>(0);

  final testRouter = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context, listen: false);
      final authState = container.read(authProvider);
      final location = state.matchedLocation;

      // Same redirect logic as app_router.dart
      if (authState is AsyncLoading) {
        return location == '/splash' ? null : '/splash';
      }
      if (authState is AsyncError) {
        return null;
      }

      final user = authState.valueOrNull;

      if (user == null) {
        if (location == '/login' || location == '/register') {
          return null;
        }
        return '/login';
      }

      if (location == '/login' || location == '/register' || location == '/waiting') {
        switch (user.status) {
          case UserStatus.pending:
            return '/waiting';
          case UserStatus.deactivated:
            return '/deactivated';
          case UserStatus.active:
            return '/home';
        }
      }

      switch (user.status) {
        case UserStatus.pending:
          if (location != '/waiting') return '/waiting';
          break;
        case UserStatus.deactivated:
          if (location != '/deactivated') return '/deactivated';
          break;
        case UserStatus.active:
          if (location != '/home') return '/home';
          break;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/waiting',
        name: 'waiting',
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
        path: '/deactivated',
        name: 'deactivated',
        builder: (context, state) => const DeactivatedScreen(),
      ),
    ],
  );

  // Listen to authProvider changes and trigger router refresh
  // We do this by wrapping in a Consumer that listens to authProvider
  return ProviderScope(
    overrides: [
      appRouterProvider.overrideWithValue(testRouter),
      ...?overrides,
    ],
    child: Consumer(
      builder: (context, ref, _) {
        ref.listen<AsyncValue<User?>>(authProvider, (_, _) {
          refreshNotifier.value++;
        });
        return MaterialApp.router(
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          builder: (context, child) => AppBackground(child: child!),
          routerConfig: testRouter,
        );
      },
    ),
  );
}

void main() {
  // Silence GoogleFonts runtime network fetches in tests (mirrors
  // test/widgets_test.dart).
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AuthRepository', () {
    test('login persists token and returns the hydrated user', () async {
      final f = _Fixtures()..loginOk('jwt-token-123');
      final repo = AuthRepository(f.api, f.storage);

      final user = await repo.login(email: 'admin@example.com', password: 'pw');

      expect(user.name, 'Admin One');
      expect(user.email, 'admin@example.com');
      expect(user.role, Role.admin);
      expect(user.status, UserStatus.active);
      expect(f.storage.token, 'jwt-token-123');
      expect(f.api._calls, ['POST /auth/login']);
    });

    test('login with wrong password throws ApiException "Invalid email or password"', () async {
      final f = _Fixtures()
        ..loginError(ApiException(message: 'Invalid email or password', statusCode: 401));
      final repo = AuthRepository(f.api, f.storage);

      expect(
        () => repo.login(email: 'admin@example.com', password: 'bad'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Invalid email or password')),
      );
      expect(f.storage.token, isNull);
    });

    test('register returns message + user and does NOT save a token', () async {
      final f = _Fixtures()..registerOk();
      final repo = AuthRepository(f.api, f.storage);

      final result = await repo.register(name: 'Reg Person', email: 'reg@example.com', password: 'pw');

      expect(result.message, 'User registered successfully');
      expect(result.user.name, 'Reg Person');
      expect(result.user.status, UserStatus.pending);
      expect(result.user.role, isNull); // PENDING users have role null
      expect(f.storage.token, isNull);
    });

    test('fetchMe returns the user', () async {
      final f = _Fixtures()..meOk();
      final repo = AuthRepository(f.api, f.storage);

      final user = await repo.fetchMe();
      expect(user.id, 'u1');
      expect(user.role, Role.admin);
    });

    test('fetchMe rethrows ApiException (e.g. 401)', () async {
      final f = _Fixtures()
        ..meError(ApiException(message: 'Invalid or expired token', statusCode: 401));
      final repo = AuthRepository(f.api, f.storage);

      expect(() => repo.fetchMe(), throwsA(isA<ApiException>()));
    });

    test('logout deletes the stored token', () async {
      final f = _Fixtures()..storage._token = 'to-delete';
      final repo = AuthRepository(f.api, f.storage);

      await repo.logout();
      expect(f.storage.token, isNull);
    });
  });

  group('authProvider build/restore', () {
    test('no token -> logged out (null)', () async {
      final f = _Fixtures();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      final result = await container.read(authProvider.future);

      expect(result, isNull);
      expect(container.read(authProvider).hasValue, isTrue);
      expect(container.read(isLoggedInProvider), isFalse);
    });

    test('valid token + /me success -> hydrates user (role ADMIN, ACTIVE)', () async {
      final f = _Fixtures()
        ..meOk()
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      await container.read(authProvider.future);
      final user = container.read(authProvider).valueOrNull;

      expect(user, isNotNull);
      expect(user!.name, 'Admin One');
      expect(user.role, Role.admin);
      expect(user.status, UserStatus.active);
      expect(container.read(isLoggedInProvider), isTrue);
      expect(container.read(currentRoleProvider), Role.admin);
      expect(f.storage.token, _validToken()); // token NOT deleted
    });

    test('expired token -> cleared and logged out', () async {
      final f = _Fixtures()..storage._token = _expiredToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      final result = await container.read(authProvider.future);

      expect(result, isNull);
      expect(f.storage.token, isNull);
    });

    test('401 from /me -> clears token and logs out', () async {
      final f = _Fixtures()
        ..meError(ApiException(message: 'Invalid or expired token', statusCode: 401))
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      final result = await container.read(authProvider.future);

      expect(result, isNull);
      expect(f.storage.token, isNull);
    });

    test('403 ("Account deactivated") -> rethrown as AsyncError, token NOT deleted', () async {
      final f = _Fixtures()
        ..meError(ApiException(message: 'Account deactivated', statusCode: 403))
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      await expectLater(container.read(authProvider.future), throwsA(isA<ApiException>()));
      expect(container.read(authProvider).hasError, isTrue);
      // Session must NOT be dropped because of a non-401 error during restore.
      expect(f.storage.token, _validToken());
    });

    test('network error -> rethrown (UI offers Retry), token NOT deleted', () async {
      final f = _Fixtures()
        ..meError(ApiException(message: 'Cannot reach the server. Check your connection.'))
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);

      await expectLater(container.read(authProvider.future), throwsA(isA<ApiException>()));
      expect(f.storage.token, _validToken()); // session preserved
    });
  });

  group('authProvider mutations', () {
    test('login() sets state to the user and saves token', () async {
      final f = _Fixtures()..loginOk('jwt-token-123');
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);
      // Let build settle to null first.
      await container.read(authProvider.future);

      final user = await container.read(authProvider.notifier).login(
            email: 'admin@example.com',
            password: 'pw',
          );

      expect(user.name, 'Admin One');
      expect(f.storage.token, 'jwt-token-123');
      expect(container.read(authProvider).valueOrNull?.name, 'Admin One');
      expect(container.read(isLoggedInProvider), isTrue);
    });

    test('login() with wrong password throws and does not flip state to error', () async {
      final f = _Fixtures()
        ..loginError(ApiException(message: 'Invalid email or password', statusCode: 401));
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);
      await container.read(authProvider.future);

      await expectLater(
        container.read(authProvider.notifier).login(email: 'a@b.c', password: 'bad'),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Invalid email or password'),
        ),
      );

      // State stays "logged out" (null), NOT AsyncError, so the login form
      // remains usable rather than being replaced by an error screen.
      expect(container.read(authProvider).valueOrNull, isNull);
      expect(f.storage.token, isNull);
    });

    test('logout() deletes the token and resets state to null', () async {
      final f = _Fixtures()
        ..meOk()
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      expect(container.read(authProvider).valueOrNull, isNotNull);

      await container.read(authProvider.notifier).logout();

      expect(f.storage.token, isNull);
      expect(container.read(authProvider).valueOrNull, isNull);
    });

    test('unauthorized event from a protected route -> logout', () async {
      final f = _Fixtures()
        ..meOk()
        ..storage._token = _validToken();
      final container = ProviderContainer(overrides: _o(f));
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      expect(container.read(authProvider).valueOrNull, isNotNull);

      // Simulate a 401 coming back from a non-auth route (e.g. tasks list).
      container.read(unauthorizedEventProvider.notifier).state =
          ApiException(message: 'Invalid or expired token', statusCode: 401);

      // The auth listener drops the session; let it run to completion.
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(authProvider).valueOrNull, isNull);
      expect(f.storage.token, isNull);
      expect(container.read(unauthorizedEventProvider), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // LoginScreen widget tests (Task 7 acceptance)
  // ---------------------------------------------------------------------------

  group('LoginScreen (Task 7)', () {
    testWidgets('logged out: shows the form and fires no request',
        (WidgetTester tester) async {
      final f = _Fixtures();
      await tester.pumpWidget(_wrap(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget); // AuthHeader title
      expect(find.text('Sign in to continue'), findsOneWidget); // subtitle
      expect(find.text('Login'), findsOneWidget); // AppButton label
      expect(f.api._calls, isEmpty);
    });

    testWidgets('empty form: shows validator messages and sends no request',
        (WidgetTester tester) async {
      final f = _Fixtures();
      await tester.pumpWidget(_wrap(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(f.api._calls, isEmpty,
          reason: 'no login call before the form is valid');
    });

    testWidgets('invalid email: shows "Enter a valid email", no request',
        (WidgetTester tester) async {
      final f = _Fixtures();
      await tester.pumpWidget(_wrap(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'not-an-email');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(f.api._calls, isEmpty);
    });

    testWidgets('wrong password -> inline "Invalid email or password"',
        (WidgetTester tester) async {
      final f = _Fixtures()
        ..loginError(ApiException(message: 'Invalid email or password', statusCode: 401));
      await tester.pumpWidget(_wrap(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'admin@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'bad');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget); // still on the form
      expect(find.text('Logged in'), findsNothing);
      expect(f.storage.token, isNull);
      expect(f.api._calls, ['POST /auth/login']);
    });

    testWidgets('deactivated user -> inline "Account deactivated"',
        (WidgetTester tester) async {
      final f = _Fixtures()
        ..loginError(ApiException(message: 'Account deactivated', statusCode: 403));
      await tester.pumpWidget(_wrap(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'admin@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Account deactivated'), findsOneWidget);
      expect(find.text('Logged in'), findsNothing);
      expect(f.storage.token, isNull);
    });

    testWidgets('correct login -> navigates to home screen',
        (WidgetTester tester) async {
      final f = _Fixtures()..loginOk('jwt-token-123');
      await tester.pumpWidget(_wrapWithRouter(const LoginScreen(), _o(f)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'admin@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'pw');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // After login, should navigate to home screen
      expect(find.text('Admin One'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(f.storage.token, 'jwt-token-123');
      expect(f.api._calls, ['POST /auth/login']);
    });

    testWidgets('no overflow on a small screen with the keyboard open',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      final f = _Fixtures();
      // Simulate the on-screen keyboard taking ~280px: inject viewInsets via a
      // MediaQuery above the Scaffold so Scaffold.resizeToAvoidBottomInset
      // (and the SingleChildScrollView) gets them. FakeViewPadding isn't part
      // of the public flutter_test API, so this avoids it.
      await tester.pumpWidget(
        ProviderScope(
          overrides: _o(f),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            builder: (context, child) => AppBackground(child: child!),
            home: MediaQuery(
              data: MediaQueryData(
                viewInsets: EdgeInsets.only(bottom: 280),
              ),
              child: const LoginScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  // Sanity check for the JWT helpers above.
  test('JWT helper tokens report expected expiry', () {
    expect(JwtDecoder.isExpired(_validToken()), isFalse);
    expect(JwtDecoder.isExpired(_expiredToken()), isTrue);
  });
}
