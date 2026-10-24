// Dashboard statistics model.
//
// Mirrors the response of GET /dashboard/stats
// (backend/src/controllers/dashboard.controller.js):
//   { totalUsers, pendingUsers, activeProjects, openTasks, doneTasks }
// plus an extra `tasksByStatus` map which we tolerate but do not model.
//
// All fields are non-negative integers; each defaults to 0 when absent so an
// empty/partial response always parses.

/// Aggregate dashboard counts returned by `GET /dashboard/stats`.
class DashboardStats {
  const DashboardStats({
    this.totalUsers = 0,
    this.pendingUsers = 0,
    this.activeProjects = 0,
    this.openTasks = 0,
    this.doneTasks = 0,
  });

  final int totalUsers;
  final int pendingUsers;
  final int activeProjects;
  final int openTasks;
  final int doneTasks;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: _asInt(json['totalUsers']) ?? 0,
      pendingUsers: _asInt(json['pendingUsers']) ?? 0,
      activeProjects: _asInt(json['activeProjects']) ?? 0,
      openTasks: _asInt(json['openTasks']) ?? 0,
      doneTasks: _asInt(json['doneTasks']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'pendingUsers': pendingUsers,
        'activeProjects': activeProjects,
        'openTasks': openTasks,
        'doneTasks': doneTasks,
      };

  @override
  String toString() => 'DashboardStats(totalUsers: $totalUsers, '
      'pendingUsers: $pendingUsers, activeProjects: $activeProjects, '
      'openTasks: $openTasks, doneTasks: $doneTasks)';
}

/// Coerces a JSON value to an [int?] tolerantly.
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
