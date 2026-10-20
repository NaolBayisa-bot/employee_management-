#!/usr/bin/env node
/**
 * End-to-end test script for the TaskApp backend.
 *
 * Uses plain Node 18+ fetch — no external dependencies.
 * Set BASE_URL env var (default http://localhost:3000) before running.
 *
 * Usage:
 *   BASE_URL=http://localhost:3000 npm run e2e
 *
 * Note: Rate limits reset on server restart. If login rate limit
 * (10 per 15 min) is hit, restart the server.
 */

const baseUrl = process.env.BASE_URL || 'http://localhost:3000';

// Seed credentials (from .env)
const ADMIN_EMAIL = 'admin@company.com';
const ADMIN_PASSWORD = 'ChangeMe123!';

// Unique email suffix to avoid collisions across runs
const ts = Date.now();
const managerEmail = `mgr_${ts}@test.com`;
const employeeEmail = `emp_${ts}@test.com`;

let adminToken, managerToken, employeeToken;
let managerId, employeeId, projectId, taskId;

// ─── Helpers ───────────────────────────────────────────

async function request(method, path, token, body) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  const opts = { method, headers };
  if (body !== undefined) opts.body = JSON.stringify(body);
  const res = await fetch(baseUrl + path, opts);
  let data;
  try { data = await res.json(); } catch { data = null; }
  return { status: res.status, data };
}

let passed = 0, failed = 0;

async function step(name, fn) {
  try {
    await fn();
    console.log('  PASS: ' + name);
    passed++;
  } catch (err) {
    console.error('  FAIL: ' + name + ' — ' + err.message);
    failed++;
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message || 'Assertion failed');
}

// ─── Flow ──────────────────────────────────────────────

async function run() {
  console.log('E2E tests against ' + baseUrl);
  console.log('');

  // 1. Admin login
  await step('1. Admin login', async () => {
    const { status, data } = await request('POST', '/auth/admin/login', null, {
      email: ADMIN_EMAIL, password: ADMIN_PASSWORD,
    });
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.token, 'No token in response');
    adminToken = data.token;
  });

  // 2. Register manager (PENDING)
  await step('2. Register manager', async () => {
    const { status, data } = await request('POST', '/auth/register', null, {
      name: 'E2E Manager', email: managerEmail, password: 'Test123!',
    });
    assert(status === 201, 'Expected 201, got ' + status);
    assert(data && data.user, 'No user in response');
    managerId = data.user.id;
    assert(data.user.status === 'PENDING', 'User should be PENDING');
  });

  // 3. Register employee (PENDING)
  await step('3. Register employee', async () => {
    const { status, data } = await request('POST', '/auth/register', null, {
      name: 'E2E Employee', email: employeeEmail, password: 'Test123!',
    });
    assert(status === 201, 'Expected 201, got ' + status);
    assert(data && data.user, 'No user in response');
    employeeId = data.user.id;
  });

  // 4. List pending users
  await step('4. List pending users', async () => {
    const { status, data } = await request('GET', '/users?status=PENDING', adminToken);
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.users, 'No users array');
    const found = data.users.filter(u => u.email === managerEmail || u.email === employeeEmail);
    assert(found.length >= 2, 'Expected 2 pending users, got ' + found.length);
  });

  // 5. Approve both users
  await step('5. Approve manager and employee', async () => {
    const r1 = await request('PATCH', '/users/' + managerId + '/approve', adminToken, { role: 'MANAGER' });
    assert(r1.status === 200, 'Approve manager: expected 200, got ' + r1.status);
    assert(r1.data && r1.data.user.status === 'ACTIVE', 'Manager not ACTIVE');
    const r2 = await request('PATCH', '/users/' + employeeId + '/approve', adminToken, { role: 'EMPLOYEE' });
    assert(r2.status === 200, 'Approve employee: expected 200, got ' + r2.status);
    assert(r2.data && r2.data.user.status === 'ACTIVE', 'Employee not ACTIVE');
  });

  // 6. Manager login
  await step('6. Manager login', async () => {
    const { status, data } = await request('POST', '/auth/login', null, {
      email: managerEmail, password: 'Test123!',
    });
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.token, 'No token in response');
    managerToken = data.token;
  });

  // 7. Employee login
  await step('7. Employee login', async () => {
    const { status, data } = await request('POST', '/auth/login', null, {
      email: employeeEmail, password: 'Test123!',
    });
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.token, 'No token in response');
    employeeToken = data.token;
  });

  // 8. Manager creates project
  await step('8. Manager creates project', async () => {
    const { status, data } = await request('POST', '/projects', managerToken, {
      name: 'E2E Project', description: 'Created by e2e script',
    });
    assert(status === 201, 'Expected 201, got ' + status);
    assert(data && data.project, 'No project in response');
    projectId = data.project.id;
  });

  // 9. Get candidates
  await step('9. Get candidates', async () => {
    const { status, data } = await request('GET', '/projects/candidates', managerToken);
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.users, 'No users in response');
    assert(data.users.length >= 1, 'Expected at least 1 candidate');
  });

  // 10. Add employee to project
  await step('10. Add employee to project', async () => {
    const { status, data } = await request('POST', '/projects/' + projectId + '/members', managerToken, {
      userId: employeeId,
    });
    assert(status === 201, 'Expected 201, got ' + status);
    assert(data && data.members, 'No members in response');
    assert(data.members.some(m => m.id === employeeId), 'Employee not in members list');
  });

  // 11. Create task assigned to employee
  await step('11. Manager creates task', async () => {
    const { status, data } = await request('POST', '/tasks', managerToken, {
      title: 'E2E Test Task', description: 'Created by manager',
      projectId: projectId, assigneeId: employeeId, priority: 'HIGH',
    });
    assert(status === 201, 'Expected 201, got ' + status);
    assert(data && data.task, 'No task in response');
    taskId = data.task.id;
    assert(data.task.status === 'TODO', 'Task should start as TODO');
  });

  // 12. Employee views tasks
  await step('12. Employee my tasks', async () => {
    const { status, data } = await request('GET', '/tasks/my', employeeToken);
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data && data.tasks, 'No tasks in response');
    assert(data.tasks.some(t => t.id === taskId), 'Task not in employee list');
  });

  // 13. Update status IN_PROGRESS then DONE
  await step('13. Employee updates status', async () => {
    const r1 = await request('PATCH', '/tasks/' + taskId + '/status', employeeToken, { status: 'IN_PROGRESS' });
    assert(r1.status === 200, 'IN_PROGRESS: expected 200, got ' + r1.status);
    assert(r1.data.task.status === 'IN_PROGRESS', 'Should be IN_PROGRESS');
    const r2 = await request('PATCH', '/tasks/' + taskId + '/status', employeeToken, { status: 'DONE' });
    assert(r2.status === 200, 'DONE: expected 200, got ' + r2.status);
    assert(r2.data.task.status === 'DONE', 'Should be DONE');
  });

  // 14. Negative tests
  await step('14. Negative tests', async () => {
    const r1 = await request('POST', '/projects', employeeToken, { name: 'Fail' });
    assert(r1.status === 403, 'Emp create project: expected 403, got ' + r1.status);
    const r2 = await request('PATCH', '/users/' + employeeId + '/approve', employeeToken, { role: 'MANAGER' });
    assert(r2.status === 403, 'Emp approve: expected 403, got ' + r2.status);
    const r3 = await request('POST', '/auth/login', null, { email: managerEmail, password: 'wrong' });
    assert(r3.status === 401, 'Wrong password: expected 401, got ' + r3.status);
  });

  // 15. Admin stats
  await step('15. Admin dashboard stats', async () => {
    const { status, data } = await request('GET', '/dashboard/stats', adminToken);
    assert(status === 200, 'Expected 200, got ' + status);
    assert(typeof data.totalUsers === 'number', 'Missing totalUsers');
    assert(typeof data.pendingUsers === 'number', 'Missing pendingUsers');
    assert(typeof data.activeProjects === 'number', 'Missing activeProjects');
    assert(typeof data.openTasks === 'number', 'Missing openTasks');
    assert(typeof data.doneTasks === 'number', 'Missing doneTasks');
    assert(data.tasksByStatus, 'Missing tasksByStatus');
    assert(typeof data.tasksByStatus.TODO === 'number', 'Missing TODO count');
  });

  // 16. Admin activity feed
  await step('16. Admin activity feed', async () => {
    const { status, data } = await request('GET', '/activity?limit=5', adminToken);
    assert(status === 200, 'Expected 200, got ' + status);
    assert(data.items, 'No items in response');
    assert(data.page === 1, 'Page should be 1');
    assert(data.limit === 5, 'Limit should be 5');
    assert(data.total > 0, 'Expected total > 0');
    assert(data.totalPages === Math.ceil(data.total / 5), 'totalPages mismatch');
    if (data.items.length >= 2) {
      assert(new Date(data.items[0].createdAt) >= new Date(data.items[1].createdAt), 'Items should be newest first');
    }
  });

  console.log('');
  console.log('Results: ' + passed + ' passed, ' + failed + ' failed');
  process.exit(failed > 0 ? 1 : 0);
}

run().catch(err => {
  console.error('Fatal error:', err.message);
  process.exit(1);
});
