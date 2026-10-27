// Tests for Task 16 (Add Members to a Project).
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:employee_management/core/network/api_client.dart';
import 'package:employee_management/core/network/api_exception.dart';
import 'package:employee_management/core/storage/secure_storage.dart';
import 'package:employee_management/features/auth/data/auth_repository.dart';
import 'package:employee_management/features/projects/data/project_repository.dart';
import 'package:employee_management/features/projects/screens/add_members_screen.dart';
import 'package:employee_management/features/projects/widgets/candidate_tile.dart';
import 'package:employee_management/shared/models/user.dart';
import 'package:employee_management/shared/widgets/app_button.dart';

String _b64(Map m) =>
    base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
String _validToken() =>
    '${_b64({'alg': 'HS256', 'typ': 'JWT'})}.${_b64({'id': 'm1', 'exp': (DateTime.now().add(const Duration(days: 1))).millisecondsSinceEpoch ~/ 1000})}.sig';

const _candidateJson = {'id': 'c1', 'name': 'Alice Dev', 'role': 'EMPLOYEE'};
const _projectJson = {
  'id': 'p1',
  'name': 'Website Redesign',
  'description': 'Modernize',
  'status': 'ACTIVE',
  'owner': {'id': 'o1', 'name': 'Owner One'},
  'members': [
    {'id': 'm1', 'name': 'Member One', 'role': 'MANAGER'},
  ],
  'createdAt': '2024-01-15T10:30:00.000Z',
};

class FakeApiClient extends ApiClient {
  FakeApiClient() : super(Dio());
  final Map<String, dynamic> _responses = {};
  final Map<String, ApiException> _errors = {};
  final List<String> _calls = [];
  void setJson(String k, Map d) => _responses[k] = d;
  void setError(String k, ApiException e) => _errors[k] = e;
  List<String> get calls => List.unmodifiable(_calls);

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final qp = queryParameters ?? {};
    final search = qp['search'] as String?;
    final suffix = search != null && search.isNotEmpty ? '?search=$search' : '';
    final key = 'GET $path$suffix';
    _calls.add(key);
    if (_errors.containsKey(key)) throw _errors[key]!;
    if (_responses.containsKey(key)) {
      return Future.value(
        Response<T>(
          data: _responses[key],
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        ),
      );
    }
    throw ApiException(message: 'no fake for $key');
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    _calls.add('POST $path');
    if (_errors.containsKey('POST $path')) throw _errors['POST $path']!;
    if (_responses.containsKey('POST $path')) {
      return Future.value(
        Response<T>(
          data: _responses['POST $path'],
          statusCode: 201,
          requestOptions: RequestOptions(path: path),
        ),
      );
    }
    throw ApiException(message: 'no fake for POST $path');
  }
}

class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage() : super(const FlutterSecureStorage());
  String? _token;
  @override
  Future<void> saveToken(String t) async => _token = t;
  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> deleteToken() async => _token = null;
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository(this._user) : super(ApiClient(Dio()), FakeTokenStorage());
  final User _user;
  @override
  Future<User> fetchMe() async => _user;
}

final managerUser = User(
  id: 'm1',
  name: 'Manager One',
  email: 'm@example.com',
  role: Role.manager,
  status: UserStatus.active,
);

ProviderContainer _containerWithOverrides(List<Override> overrides) {
  return ProviderContainer(overrides: overrides);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ProjectRepository', () {
    late FakeApiClient api;
    late ProjectRepository repo;
    setUp(() {
      api = FakeApiClient();
      repo = ProjectRepository(api);
    });

    group('getCandidates', () {
      test('returns parsed Candidate list', () async {
        api.setJson('GET /projects/candidates', {
          'users': [_candidateJson],
        });
        final result = await repo.getCandidates();
        expect(api.calls, ['GET /projects/candidates']);
        expect(result, hasLength(1));
        expect(result.first.id, 'c1');
        expect(result.first.name, 'Alice Dev');
        expect(result.first.role, Role.employee);
      });

      test('sends search param', () async {
        api.setJson('GET /projects/candidates?search=alice', {
          'users': [_candidateJson],
        });
        await repo.getCandidates(search: 'alice');
        expect(api.calls, ['GET /projects/candidates?search=alice']);
      });

      test('returns empty when users absent', () async {
        api.setJson('GET /projects/candidates', {});
        final result = await repo.getCandidates();
        expect(result, isEmpty);
      });
    });

    group('addMember', () {
      test('posts {userId}', () async {
        api.setJson('POST /projects/p1/members', {
          'members': [_candidateJson],
        });
        final result = await repo.addMember('p1', 'c1');
        expect(api.calls, ['POST /projects/p1/members']);
        expect(result, hasLength(1));
      });

      test('throws on 409', () async {
        api.setError(
          'POST /projects/p1/members',
          ApiException(message: 'User is already a member', statusCode: 409),
        );
        expect(
          () => repo.addMember('p1', 'c1'),
          throwsA(
            predicate<ApiException>(
              (e) =>
                  e.statusCode == 409 &&
                  e.message == 'User is already a member',
            ),
          ),
        );
      });
    });
  });

  group('CandidateTile widget', () {
    Widget wrapTile(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

    testWidgets('renders Add button', (WidgetTester t) async {
      await t.pumpWidget(
        wrapTile(
          CandidateTile(
            candidate: Candidate(
              id: 'c1',
              name: 'Alice Dev',
              role: Role.employee,
            ),
            isMember: false,
            onAdd: () {},
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Alice Dev'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('renders Member label', (WidgetTester t) async {
      await t.pumpWidget(
        wrapTile(
          CandidateTile(
            candidate: Candidate(
              id: 'c1',
              name: 'Alice Dev',
              role: Role.employee,
            ),
            isMember: true,
            onAdd: () {},
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('Add button disabled while loading', (WidgetTester t) async {
      int taps = 0;
      await t.pumpWidget(
        wrapTile(
          CandidateTile(
            candidate: Candidate(
              id: 'c1',
              name: 'Alice Dev',
              role: Role.employee,
            ),
            isMember: false,
            onAdd: () => taps++,
            isLoading: true,
          ),
        ),
      );
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.tap(find.byType(AppButton));
      await t.pump();
      expect(taps, 0);
    });

    testWidgets('invokes onAdd when tapped', (WidgetTester t) async {
      int taps = 0;
      await t.pumpWidget(
        wrapTile(
          CandidateTile(
            candidate: Candidate(
              id: 'c1',
              name: 'Alice Dev',
              role: Role.employee,
            ),
            isMember: false,
            onAdd: () => taps++,
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Add'));
      await t.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('AddMembersScreen widget', () {
    late FakeApiClient api;
    setUp(() {
      api = FakeApiClient();
    });

    List<Override> makeAuthOverrides() => [
      tokenStorageProvider.overrideWithValue(
        FakeTokenStorage().._token = _validToken(),
      ),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository(managerUser)),
      projectRepositoryProvider.overrideWithValue(ProjectRepository(api)),
    ];

    Widget wrapScreen(Widget child, List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: ThemeData.dark(), home: child),
    );

    testWidgets('renders search field and candidates', (WidgetTester t) async {
      final overrides = makeAuthOverrides();
      api.setJson('GET /projects/p1', _projectJson);
      api.setJson('GET /projects/candidates', {
        'users': [
          _candidateJson,
          {'id': 'c2', 'name': 'Bob Dev', 'role': 'EMPLOYEE'},
        ],
      });
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Add Members'), findsOneWidget);
      expect(find.text('Alice Dev'), findsOneWidget);
      expect(find.text('Bob Dev'), findsOneWidget);
      expect(find.text('Add'), findsNWidgets(2));
    });

    testWidgets('marks existing members as Member label', (
      WidgetTester t,
    ) async {
      final overrides = makeAuthOverrides();
      api.setJson('GET /projects/p1', _projectJson);
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Member One'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('debounces search 400ms before fetching', (
      WidgetTester t,
    ) async {
      final overrides = makeAuthOverrides();
      api.setJson('GET /projects/candidates', {
        'users': [_candidateJson],
      });
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      await t.enterText(find.byType(TextFormField), 'Alice');
      await t.pump();
      expect(api.calls.where((c) => c.contains('search=Alice')), isEmpty);
      await t.pump(const Duration(milliseconds: 500));
      expect(api.calls.any((c) => c.contains('search=Alice')), isTrue);
    });

    testWidgets('shows success snackbar after add', (WidgetTester t) async {
      final overrides = makeAuthOverrides();
      api.setJson('GET /projects/p1', _projectJson);
      api.setJson('GET /projects/candidates', {
        'users': [_candidateJson],
      });
      api.setJson('POST /projects/p1/members', {
        'members': [_candidateJson],
      });
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      await t.tap(find.text('Add').first);
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Alice Dev added to project'), findsOneWidget);
    });

    testWidgets('shows server 409 when adding again', (WidgetTester t) async {
      final overrides = makeAuthOverrides();
      api.setError(
        'POST /projects/p1/members',
        ApiException(message: 'User is already a member', statusCode: 409),
      );
      api.setJson('GET /projects/p1', _projectJson);
      api.setJson('GET /projects/candidates', {
        'users': [
          _candidateJson,
          {'id': 'c2', 'name': 'Bob Dev', 'role': 'EMPLOYEE'},
        ],
      });
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      await t.tap(find.text('Add').last);
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('User is already a member'), findsOneWidget);
    });

    testWidgets('shows error state on candidates failure', (
      WidgetTester t,
    ) async {
      final overrides = makeAuthOverrides();
      api.setError(
        'GET /projects/candidates',
        ApiException(message: 'Cannot reach server', statusCode: 500),
      );
      api.setJson('GET /projects/p1', _projectJson);
      await t.pumpWidget(
        wrapScreen(const AddMembersScreen(projectId: 'p1'), overrides),
      );
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Failed to load candidates'), findsOneWidget);
    });
  });
}
