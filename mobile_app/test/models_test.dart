import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management/shared/models.dart';

void main() {
  String pad2(int v) => v.toString().padLeft(2, '0');

  String todayStr() {
    final now = DateTime.now();
    return '${now.year}-${pad2(now.month)}-${pad2(now.day)}';
  }

  String yesterdayStr() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${pad2(y.month)}-${pad2(y.day)}';
  }

  group('Role', () {
    test('round-trips to/from UPPER-CASE server strings', () {
      expect(Role.admin.toServerValue(), 'ADMIN');
      expect(Role.manager.toServerValue(), 'MANAGER');
      expect(Role.employee.toServerValue(), 'EMPLOYEE');
      expect(Role.fromServer('ADMIN'), Role.admin);
      expect(Role.fromServer('MANAGER'), Role.manager);
      expect(Role.fromServer('EMPLOYEE'), Role.employee);
    });

    test('fromServer returns null for null/unknown', () {
      expect(Role.fromServer(null), isNull);
      expect(Role.fromServer('SUPERADMIN'), isNull);
      // value is null on the server for PENDING users.
    });
  });

  group('UserStatus', () {
    test('matches real backend ENUM values', () {
      expect(UserStatus.fromServer('PENDING'), UserStatus.pending);
      expect(UserStatus.fromServer('ACTIVE'), UserStatus.active);
      expect(UserStatus.fromServer('DEACTIVATED'), UserStatus.deactivated);
    });

    test('README "INACTIVE" is NOT a backend value -> falls back to pending', () {
      // README master context lists INACTIVE, but the real ENUM is DEACTIVATED.
      expect(UserStatus.fromServer('INACTIVE'), UserStatus.pending);
      expect(UserStatus.fromServer(null), UserStatus.pending);
    });

    test('round-trips', () {
      expect(UserStatus.pending.toServerValue(), 'PENDING');
      expect(UserStatus.active.toServerValue(), 'ACTIVE');
      expect(UserStatus.deactivated.toServerValue(), 'DEACTIVATED');
    });
  });

  group('UserRef', () {
    test('parses {id, name}', () {
      final ref = UserRef.fromJson({'id': 'u1', 'name': 'Alice'});
      expect(ref.id, 'u1');
      expect(ref.name, 'Alice');
      expect(ref.toJson(), {'id': 'u1', 'name': 'Alice'});
    });

    test('throws FormatException when missing id/name', () {
      expect(() => UserRef.fromJson(null), throwsFormatException);
      expect(() => UserRef.fromJson({'name': 'Alice'}), throwsFormatException);
      expect(() => UserRef.fromJson({'id': 'u1'}), throwsFormatException);
    });
  });

  group('ProjectMember', () {
    test('parses with null role', () {
      final m = ProjectMember.fromJson(
        {'id': 'u2', 'name': 'Bob', 'role': null},
      );
      expect(m.id, 'u2');
      expect(m.name, 'Bob');
      expect(m.role, isNull);
    });

    test('parses known role', () {
      final m = ProjectMember.fromJson(
        {'id': 'u3', 'name': 'Carol', 'role': 'EMPLOYEE'},
      );
      expect(m.role, Role.employee);
      expect(m.toJson()['role'], 'EMPLOYEE');
    });
  });

  group('User', () {
    final Map<String, dynamic> sample = {
      'id': 'u-1',
      'name': 'Alice',
      'email': 'alice@example.com',
      'role': 'MANAGER',
      'status': 'ACTIVE',
      'createdAt': '2024-01-15T10:30:00.000Z',
    };

    test('parses full sample from backend toJSON', () {
      final user = User.fromJson(sample);
      expect(user.id, 'u-1');
      expect(user.name, 'Alice');
      expect(user.email, 'alice@example.com');
      expect(user.role, Role.manager);
      expect(user.status, UserStatus.active);
      expect(user.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    // A user with role: null (e.g. a freshly-registered PENDING user).
    test('parses user with role null and status PENDING', () {
      final user = User.fromJson({
        'id': 'u-2',
        'name': 'Bob',
        'email': 'bob@example.com',
        'role': null,
        'status': 'PENDING',
        'createdAt': null,
      });
      expect(user.role, isNull);
      expect(user.status, UserStatus.pending);
      expect(user.createdAt, isNull);
    });

    test('tolerates missing optional fields', () {
      final user = User.fromJson(
        {'id': 'u-3', 'name': 'Carol', 'email': 'c@e.com'},
      );
      expect(user.role, isNull);
      expect(user.status, UserStatus.pending); // backend default
      expect(user.createdAt, isNull);
    });

    test('tolerates unknown/backend-only fields', () {
      final user = User.fromJson({
        'id': 'u-4',
        'name': 'Dan',
        'email': 'd@e.com',
        'role': 'EMPLOYEE',
        'status': 'ACTIVE',
        'passwordHash': 'secret', // must be ignored
        'updatedAt': '2024-01-01T00:00:00.000Z', // must be ignored
      });
      expect(user.id, 'u-4');
      expect(user.name, 'Dan');
      expect(user.status, UserStatus.active);
    });

    test('throws FormatException for missing required id/name/email', () {
      expect(
        () => User.fromJson({'name': 'X', 'email': 'x@e.com'}),
        throwsFormatException,
      );
      expect(
        () => User.fromJson({'id': 'u', 'email': 'x@e.com'}),
        throwsFormatException,
      );
      expect(
        () => User.fromJson({'id': 'u', 'name': 'X'}),
        throwsFormatException,
      );
    });
  });

  group('ProjectStatus', () {
    test('matches real backend ENUM values', () {
      expect(ProjectStatus.fromServer('ACTIVE'), ProjectStatus.active);
      expect(ProjectStatus.fromServer('ARCHIVED'), ProjectStatus.archived);
    });

    test('README "INACTIVE" is NOT a backend value -> falls back to active', () {
      expect(ProjectStatus.fromServer('INACTIVE'), ProjectStatus.active);
      expect(ProjectStatus.fromServer(null), ProjectStatus.active);
    });

    test('round-trips', () {
      expect(ProjectStatus.active.toServerValue(), 'ACTIVE');
      expect(ProjectStatus.archived.toServerValue(), 'ARCHIVED');
    });
  });

  group('Project', () {
    test('parses list endpoint shape (memberCount, taskCount, no members)', () {
      final p = Project.fromJson({
        'id': 'p-1',
        'name': 'Alpha',
        'description': 'desc',
        'status': 'ACTIVE',
        'owner': {'id': 'u-1', 'name': 'Alice'},
        'memberCount': 3,
        'taskCount': 0,
        'createdAt': '2024-02-01T00:00:00.000Z',
      });
      expect(p.memberCount, 3);
      expect(p.taskCount, 0);
      expect(p.members, isEmpty);
      expect(p.owner, isNotNull);
      expect(p.owner!.id, 'u-1');
      expect(p.status, ProjectStatus.active);
      expect(p.createdAt, DateTime.parse('2024-02-01T00:00:00.000Z'));
    });

    test('parses detail endpoint shape (members, no counts)', () {
      final p = Project.fromJson({
        'id': 'p-1',
        'name': 'Alpha',
        'description': null,
        'status': 'ARCHIVED',
        'owner': {'id': 'u-1', 'name': 'Alice'},
        'members': [
          {'id': 'u-2', 'name': 'Bob', 'role': null},
          {'id': 'u-3', 'name': 'Carol', 'role': 'EMPLOYEE'},
        ],
        'createdAt': '2024-02-01T00:00:00.000Z',
      });
      expect(p.memberCount, 0);
      expect(p.taskCount, 0);
      expect(p.members.length, 2);
      expect(p.members[0].role, isNull);
      expect(p.members[1].role, Role.employee);
      expect(p.status, ProjectStatus.archived);
    });

    test('parses create endpoint shape (memberCount, no taskCount/members)', () {
      final p = Project.fromJson({
        'id': 'p-2',
        'name': 'Beta',
        'description': null,
        'status': 'ACTIVE',
        'owner': {'id': 'u-1', 'name': 'Alice'},
        'memberCount': 1,
        'createdAt': '2024-02-02T00:00:00.000Z',
      });
      expect(p.taskCount, 0);
      expect(p.members, isEmpty);
      expect(p.memberCount, 1);
    });

    test('tolerates null owner and missing optional fields', () {
      final p = Project.fromJson({
        'id': 'p-3',
        'name': 'Gamma',
        'status': 'ACTIVE',
      });
      expect(p.owner, isNull);
      expect(p.memberCount, 0);
      expect(p.taskCount, 0);
      expect(p.members, isEmpty);
      expect(p.description, isNull);
      expect(p.createdAt, isNull);
    });

    test('throws FormatException for missing id/name', () {
      expect(() => Project.fromJson({'name': 'X'}), throwsFormatException);
      expect(() => Project.fromJson({'id': 'p'}), throwsFormatException);
    });
  });

  group('ProjectRef', () {
    test('parses {id, name}', () {
      final ref = ProjectRef.fromJson({'id': 'p-1', 'name': 'Alpha'});
      expect(ref.id, 'p-1');
      expect(ref.name, 'Alpha');
      expect(ProjectRef.tryFromJson(null), isNull);
    });
  });

  group('TaskStatus', () {
    test('labels match spec', () {
      expect(TaskStatus.todo.label, 'To do');
      expect(TaskStatus.inProgress.label, 'In progress');
      expect(TaskStatus.done.label, 'Done');
    });

    test('round-trips and tolerates unknown', () {
      expect(TaskStatus.todo.toServerValue(), 'TODO');
      expect(TaskStatus.inProgress.toServerValue(), 'IN_PROGRESS');
      expect(TaskStatus.done.toServerValue(), 'DONE');
      expect(TaskStatus.fromServer('TODO'), TaskStatus.todo);
      expect(TaskStatus.fromServer('IN_PROGRESS'), TaskStatus.inProgress);
      expect(TaskStatus.fromServer('DONE'), TaskStatus.done);
      expect(TaskStatus.fromServer(null), TaskStatus.todo);
      expect(TaskStatus.fromServer('GARBLED'), TaskStatus.todo);
    });
  });

  group('TaskPriority', () {
    test('labels match spec', () {
      expect(TaskPriority.low.label, 'Low');
      expect(TaskPriority.medium.label, 'Medium');
      expect(TaskPriority.high.label, 'High');
    });

    test('has exactly LOW, MEDIUM, HIGH (no CRITICAL)', () {
      expect(
        TaskPriority.values,
        unorderedEquals([
          TaskPriority.low,
          TaskPriority.medium,
          TaskPriority.high,
        ]),
      );
      expect(TaskPriority.low.toServerValue(), 'LOW');
      expect(TaskPriority.high.toServerValue(), 'HIGH');
      // README documents CRITICAL; the real backend ENUM has none.
      expect(TaskPriority.fromServer('CRITICAL'), TaskPriority.medium);
    });
  });

  group('Task', () {
    test('parses full detail shape with nested project/assignee/createdBy', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Write docs',
        'description': 'desc',
        'projectId': 'p-1',
        'assigneeId': 'u-3',
        'createdById': 'u-1',
        'priority': 'HIGH',
        'dueDate': '2024-01-20',
        'status': 'TODO',
        'project': {'id': 'p-1', 'name': 'Alpha'},
        'assignee': {'id': 'u-3', 'name': 'Carol'},
        'createdBy': {'id': 'u-1', 'name': 'Alice'},
        'createdAt': '2024-01-15T10:30:00.000Z',
        'updatedAt': '2024-01-16T10:30:00.000Z',
      });
      expect(task.id, 't-1');
      expect(task.title, 'Write docs');
      expect(task.description, 'desc');
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.todo);
      expect(task.projectId, 'p-1');
      expect(task.dueDate, DateTime(2024, 1, 20));
      expect(task.project!.id, 'p-1');
      expect(task.assignee!.name, 'Carol');
      expect(task.createdBy!.name, 'Alice');
      expect(task.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    // A task with assignee: null.
    test('parses task with assignee null', () {
      final task = Task.fromJson({
        'id': 't-2',
        'title': 'My task',
        'description': null,
        'projectId': 'p-1',
        'assigneeId': null,
        'createdById': 'u-1',
        'priority': 'MEDIUM',
        'dueDate': null,
        'status': 'IN_PROGRESS',
        'createdAt': '2024-01-15T10:30:00.000Z',
      });
      expect(task.assignee, isNull);
      expect(task.createdBy, isNull); // absent on this endpoint shape
      expect(task.project, isNull); // absent
      expect(task.priority, TaskPriority.medium);
      expect(task.status, TaskStatus.inProgress);
      expect(task.dueDate, isNull);
      expect(task.description, isNull);
    });

    test('parses getProjectTasks shape (assignee present, no project/createdBy)',
        () {
      final task = Task.fromJson({
        'id': 't-3',
        'title': 'Team task',
        'projectId': 'p-1',
        'assigneeId': 'u-3',
        'createdById': 'u-1',
        'priority': 'LOW',
        'dueDate': '2099-12-31',
        'status': 'DONE',
        'assignee': {'id': 'u-3', 'name': 'Carol'},
        'createdAt': '2024-01-15T10:30:00.000Z',
      });
      expect(task.assignee!.name, 'Carol');
      expect(task.project, isNull);
      expect(task.createdBy, isNull);
      expect(task.status, TaskStatus.done);
    });

    test('dueDate parsed as local date-only (YYYY-MM-DD), no tz shift', () {
      final task = Task.fromJson({
        'id': 't',
        'title': 'x',
        'projectId': 'p',
        'dueDate': '2024-01-20',
      });
      expect(task.dueDate, DateTime(2024, 1, 20));
      expect(task.dueDate!.hour, 0);
      expect(task.dueDate!.minute, 0);
    });

    test('dueDate tolerates ISO datetime by taking date portion', () {
      final task = Task.fromJson({
        'id': 't',
        'title': 'x',
        'projectId': 'p',
        'dueDate': '2024-01-20T05:00:00.000Z',
      });
      expect(task.dueDate, DateTime(2024, 1, 20));
    });

    test('tolerates missing optional fields and unknown fields', () {
      final task = Task.fromJson(
        {'id': 't', 'title': 'x', 'projectId': 'p', 'foo': 'bar', 'extra': 123},
      );
      expect(task.description, isNull);
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.medium);
      expect(task.project, isNull);
      expect(task.assignee, isNull);
      expect(task.createdBy, isNull);
      expect(task.dueDate, isNull);
      expect(task.createdAt, isNull);
    });

    group('isOverdue', () {
      Map<String, dynamic> taskMap(String due, String status) => {
            'id': 't',
            'title': 'x',
            'projectId': 'p',
            'dueDate': due,
            'status': status,
          };

      test('past due date and not done is overdue', () {
        expect(Task.fromJson(taskMap('2020-01-01', 'TODO')).isOverdue, isTrue);
      });

      test('today is NOT overdue', () {
        expect(Task.fromJson(taskMap(todayStr(), 'TODO')).isOverdue, isFalse);
      });

      test('yesterday is overdue', () {
        expect(
          Task.fromJson(taskMap(yesterdayStr(), 'IN_PROGRESS')).isOverdue,
          isTrue,
        );
      });

      test('future is not overdue', () {
        expect(
          Task.fromJson(taskMap('2099-12-31', 'TODO')).isOverdue,
          isFalse,
        );
      });

      test('done is never overdue even if past', () {
        expect(Task.fromJson(taskMap('2020-01-01', 'DONE')).isOverdue, isFalse);
      });

      test('no dueDate is never overdue', () {
        expect(
          Task.fromJson({
            'id': 't',
            'title': 'x',
            'projectId': 'p',
            'status': 'TODO',
          }).isOverdue,
          isFalse,
        );
      });
    });

    test('throws FormatException for missing required id/title/projectId', () {
      expect(
        () => Task.fromJson({'title': 'x', 'projectId': 'p'}),
        throwsFormatException,
      );
      expect(
        () => Task.fromJson({'id': 't', 'projectId': 'p'}),
        throwsFormatException,
      );
      expect(
        () => Task.fromJson({'id': 't', 'title': 'x'}),
        throwsFormatException,
      );
    });
  });

  group('DashboardStats', () {
    test('parses full sample incl. extra tasksByStatus (ignored)', () {
      final stats = DashboardStats.fromJson({
        'totalUsers': 10,
        'pendingUsers': 3,
        'activeProjects': 5,
        'openTasks': 12,
        'doneTasks': 7,
        'tasksByStatus': {'TODO': 5, 'IN_PROGRESS': 7, 'DONE': 7},
      });
      expect(stats.totalUsers, 10);
      expect(stats.pendingUsers, 3);
      expect(stats.activeProjects, 5);
      expect(stats.openTasks, 12);
      expect(stats.doneTasks, 7);
      expect(stats.toJson(), {
        'totalUsers': 10,
        'pendingUsers': 3,
        'activeProjects': 5,
        'openTasks': 12,
        'doneTasks': 7,
      });
    });

    test('defaults all fields to 0 when absent', () {
      final stats = DashboardStats.fromJson({});
      expect(stats.totalUsers, 0);
      expect(stats.pendingUsers, 0);
      expect(stats.activeProjects, 0);
      expect(stats.openTasks, 0);
      expect(stats.doneTasks, 0);
    });
  });
}
