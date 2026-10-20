const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize, requireActive } = require('../middleware/authorize');
const { createTask, getMyTasks, getTask, updateTask, updateTaskStatus } = require('../controllers/task.controller');

const router = express.Router();

// Every route requires authentication + ACTIVE status
router.use(authenticate, requireActive);

// POST /tasks — MANAGER or ADMIN only
router.post(
  '/',
  authorize('MANAGER', 'ADMIN'),
  [
    body('title')
      .isString()
      .withMessage('Title must be a string')
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Title must be between 2 and 200 characters'),
    body('description')
      .optional()
      .isString()
      .isLength({ max: 5000 })
      .withMessage('Description must be at most 5000 characters'),
    body('projectId')
      .isUUID()
      .withMessage('Project id must be a valid UUID'),
    body('assigneeId')
      .optional()
      .isUUID()
      .withMessage('Assignee id must be a valid UUID'),
    body('dueDate')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('Due date must be a valid date (YYYY-MM-DD)'),
    body('priority')
      .optional()
      .isIn(['LOW', 'MEDIUM', 'HIGH'])
      .withMessage('Priority must be LOW, MEDIUM, or HIGH'),
  ],
  validate,
  createTask
);

// GET /tasks/my — all active users see tasks assigned to them
// MUST be registered BEFORE /:id so "my" is not treated as an id
router.get(
  '/my',
  [
    query('status')
      .optional()
      .isIn(['TODO', 'IN_PROGRESS', 'DONE'])
      .withMessage('Status must be TODO, IN_PROGRESS, or DONE'),
  ],
  validate,
  getMyTasks
);

// GET /tasks/:id — task detail
router.get(
  '/:id',
  [param('id').isUUID().withMessage('Invalid task id')],
  validate,
  getTask
);

// PATCH /tasks/:id — update task (MANAGER, ADMIN only)
router.patch(
  '/:id',
  authorize('MANAGER', 'ADMIN'),
  [
    param('id').isUUID().withMessage('Invalid task id'),
    body('title')
      .optional()
      .isString()
      .withMessage('Title must be a string')
      .trim()
      .isLength({ min: 2, max: 200 })
      .withMessage('Title must be between 2 and 200 characters'),
    body('description')
      .optional({ nullable: true })
      .isString()
      .isLength({ max: 5000 })
      .withMessage('Description must be at most 5000 characters'),
    body('dueDate')
      .optional({ nullable: true })
      .isISO8601({ strict: true })
      .withMessage('Due date must be a valid date (YYYY-MM-DD)'),
    body('priority')
      .optional()
      .isIn(['LOW', 'MEDIUM', 'HIGH'])
      .withMessage('Priority must be LOW, MEDIUM, or HIGH'),
    body('assigneeId')
      .optional({ nullable: true })
      .isUUID()
      .withMessage('Assignee id must be a valid UUID'),
  ],
  validate,
  updateTask
);

// PATCH /tasks/:id/status — update task status
// Allowed for: the assignee, a MANAGER who is a member of the project, or ADMIN
router.patch(
  '/:id/status',
  [
    param('id').isUUID().withMessage('Invalid task id'),
    body('status')
      .isIn(['TODO', 'IN_PROGRESS', 'DONE'])
      .withMessage('Status must be TODO, IN_PROGRESS, or DONE'),
  ],
  validate,
  updateTaskStatus
);

module.exports = router;
