# TaskApp Backend API

A comprehensive employee management backend with JWT authentication, role-based authorization, project management, task tracking, activity logging, and dashboard analytics.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Database Setup](#database-setup)
- [Environment Variables](#environment-variables)
- [Installation](#installation)
- [Running the Server](#running-the-server)
- [Seeding the Admin User](#seeding-the-admin-user)
- [Running Tests](#running-tests)
- [Finding Your Local IP](#finding-your-local-ip)
- [API Reference](#api-reference)
- [Postman Collection](#postman-collection)
- [Rate Limiting](#rate-limiting)

## Prerequisites

- **Node.js** 18.0+ (uses native `fetch`)
- **PostgreSQL** 12+

## Quick Start

```bash
# 1. Create database
createdb taskapp

# 2. Copy and edit .env
cp .env.example .env
# Edit .env with your database credentials

# 3. Install dependencies
npm install

# 4. Seed admin user
npm run seed

# 5. Start development server
npm run dev
```

## Database Setup

1. **Install PostgreSQL** (if not already installed).

2. **Start PostgreSQL** service:
```bash
# Linux
sudo service postgresql start

# macOS
brew services start postgresql
```

3. **Create the database** (using psql or any GUI):
```sql
CREATE DATABASE taskapp;
```

4. **Create a database user** (optional but recommended):
```sql
CREATE USER taskapp_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE taskapp TO taskapp_user;
```

## Environment Variables

Create a `.env` file in the backend root. See `.env.example` for all options:

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | Server port |
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_NAME` | `taskapp` | Database name |
| `DB_USER` | `postgres` | Database user |
| `DB_PASSWORD` | — | Database password |
| `JWT_SECRET` | — | **Required.** JWT signing secret (min 32 chars recommended) |
| `JWT_EXPIRES_IN` | `1d` | JWT token expiry (e.g., `1d`, `7d`, `12h`) |
| `CORS_ORIGIN` | `*` | CORS allowed origin |
| `ADMIN_NAME` | `Admin` | Seed admin display name |
| `ADMIN_EMAIL` | `admin@company.com` | Seed admin email |
| `ADMIN_PASSWORD` | — | **Required for seeding.** Seed admin password |
| `AUTH_LOGIN_MAX` | `10` | Max login attempts per window |
| `AUTH_LOGIN_WINDOW_MS` | `900000` | Login rate limit window (15 min) |
| `AUTH_REGISTER_MAX` | `10` | Max registration attempts per window |
| `AUTH_REGISTER_WINDOW_MS` | `3600000` | Registration rate limit window (1 hour) |

> **Important:** `DB_PASSWORD`, `JWT_SECRET`, and `ADMIN_PASSWORD` have no defaults and must be set.

## Installation

```bash
npm install
```

## Running the Server

```bash
# Development (with auto-reload via nodemon)
npm run dev

# Production
npm start
```

The server will start on the port specified in `.env` (default `3000`).

## Seeding the Admin User

```bash
npm run seed
```

This creates an admin user with credentials from your `.env`:
- **Email:** `ADMIN_EMAIL` (default: `admin@company.com`)
- **Password:** `ADMIN_PASSWORD`

The admin is created with role `ADMIN` and status `ACTIVE`. Running the script multiple times is safe — it skips if the admin already exists.

## Running Tests

The e2e test script uses native `fetch` (Node 18+) — no test framework needed.

**Prerequisites:** Server must be running and admin user must be seeded.

```bash
# Terminal 1 — start server
npm run dev

# Terminal 2 — run tests
npm run e2e
```

The script:
1. Logs in as admin
2. Registers a manager and an employee
3. Lists pending users, approves both
4. Logs in as manager and employee
5. Manager creates a project and task assigned to the employee
6. Employee views their tasks and updates status
7. Runs negative tests (access control, wrong password)
8. Fetches dashboard stats and activity feed

Each run uses unique email addresses (timestamp-based), so it can be run multiple times without conflicts.

## Finding Your Local IP

To test from a phone on the same network:

```bash
# Linux
ip addr show | grep 'inet '

# macOS
ifconfig | grep 'inet '

# Or use hostname
hostname -I
```

Then set `CORS_ORIGIN` in `.env` to your frontend URL (or `*` for testing), and access the API via `http://<your-ip>:3000/auth/me`.

## API Reference

All authenticated endpoints require a Bearer token in the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

### Auth Endpoints

| Method | Path | Auth | Description | Body | Response |
|--------|------|------|-------------|------|----------|
| POST | `/auth/register` | PUBLIC | Register a new user | `name`, `email`, `password` | `{ message, user }` |
| POST | `/auth/login` | PUBLIC | Login as any ACTIVE user | `email`, `password` | `{ token, user }` |
| POST | `/auth/admin/login` | PUBLIC | Admin login (ADMIN role required) | `email`, `password` | `{ token, user }` |
| GET | `/auth/me` | ACTIVE+ | Get current user profile | — | `{ user }` |

### User Management (Admin only)

| Method | Path | Auth | Description | Body | Response |
|--------|------|------|-------------|------|----------|
| GET | `/users` | ADMIN | List users (filter: `status`, `search`) | — | `{ users, page, limit, total, totalPages }` |
| PATCH | `/users/:id/approve` | ADMIN | Approve a PENDING user | `role` | `{ user }` |
| PATCH | `/users/:id/role` | ADMIN | Update user role | `role` | `{ user }` |
| PATCH | `/users/:id/deactivate` | ADMIN | Deactivate a user | — | `{ user }` |
| PATCH | `/users/:id/reactivate` | ADMIN | Reactivate a user | — | `{ user }` |

### Project Endpoints

| Method | Path | Auth | Description | Body | Response |
|--------|------|------|-------------|------|----------|
| POST | `/projects` | MANAGER/ADMIN | Create a new project | `name`, `description` | `{ project }` |
| GET | `/projects` | ACTIVE | List all projects (filter: `status`) | — | `{ projects, page, limit, total, totalPages }` |
| GET | `/projects/candidates` | MANAGER/ADMIN | List eligible project members | `search` (query) | `{ users }` |
| POST | `/projects/:id/members` | ADMIN or project owner | Add a member to a project | `userId` | `{ members }` |
| GET | `/projects/:id` | ACTIVE | Get project detail | — | `{ project }` |
| PATCH | `/projects/:id` | ADMIN or project owner | Update project | `name`, `description`, `status` | `{ project }` |

### Task Endpoints

| Method | Path | Auth | Description | Body | Response |
|--------|------|------|-------------|------|----------|
| POST | `/tasks` | MANAGER/ADMIN | Create a new task | `title`, `description`, `projectId`, `assigneeId`, `dueDate`, `priority` | `{ task }` |
| GET | `/tasks/my` | ACTIVE | List tasks assigned to current user | `status` (query) | `{ tasks }` |
| GET | `/tasks/:id` | ACTIVE | Get task detail | — | `{ task }` |
| PATCH | `/tasks/:id` | MANAGER/ADMIN | Update task details | `title`, `description`, `dueDate`, `priority`, `assigneeId` | `{ task }` |
| PATCH | `/tasks/:id/status` | assignee or MANAGER/ADMIN | Update task status | `status` | `{ task }` |

### Activity & Dashboard (Admin only)

| Method | Path | Auth | Description | Body | Response |
|--------|------|------|-------------|------|----------|
| GET | `/activity` | ADMIN | Activity log feed | `page`, `limit`, `userId`, `action`, `entityType`, `from`, `to` | `{ items, page, limit, total, totalPages }` |
| GET | `/dashboard/stats` | ADMIN | Dashboard statistics | — | `{ totalUsers, pendingUsers, activeProjects, openTasks, doneTasks, tasksByStatus }` |

### Response Shapes

**User object:**
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "MANAGER",
  "status": "ACTIVE",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

**Project object:**
```json
{
  "id": "uuid",
  "name": "Project Name",
  "description": "Project description",
  "status": "ACTIVE",
  "ownerId": "uuid",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

**Task object:**
```json
{
  "id": "uuid",
  "title": "Task title",
  "description": "Task description",
  "status": "TODO",
  "priority": "HIGH",
  "projectId": "uuid",
  "assigneeId": "uuid",
  "dueDate": "2024-01-20T00:00:00.000Z",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

### Roles & Status Values

| Enum | Values |
|------|--------|
| **Role** | `ADMIN`, `MANAGER`, `EMPLOYEE` |
| **User Status** | `PENDING`, `ACTIVE`, `INACTIVE` |
| **Task Status** | `TODO`, `IN_PROGRESS`, `DONE` |
| **Task Priority** | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| **Project Status** | `ACTIVE`, `INACTIVE` |

## Postman Collection

A Postman collection and environment are provided in the `docs/` directory at the repo root:

- **Collection:** `../docs/postman_collection.json`
- **Environment:** `../docs/postman_environment.json`

Import both into Postman, start the server, seed the admin, and run the collection in order. The collection includes test scripts that assert status codes and save tokens/IDs into environment variables.

## Rate Limiting

| Endpoint | Limit | Window |
|----------|-------|--------|
| `POST /auth/login` and `POST /auth/admin/login` | 10 requests | 15 minutes |
| `POST /auth/register` | 10 requests | 1 hour |
| All other API endpoints | 100 requests | 15 minutes |

Rate limits are configurable via environment variables (`AUTH_LOGIN_MAX`, `AUTH_LOGIN_WINDOW_MS`, `AUTH_REGISTER_MAX`, `AUTH_REGISTER_WINDOW_MS`).
