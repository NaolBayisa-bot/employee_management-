const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize, requireActive } = require('../middleware/authorize');
const { createProject, listProjects, getCandidates, getProject, updateProject, addMember } = require('../controllers/project.controller');
const { getProjectTasks } = require('../controllers/task.controller');

const router = express.Router();

// Every route requires authentication + ACTIVE status
router.use(authenticate, requireActive);

// POST /projects — MANAGER or ADMIN only
router.post(
  '/',
  authorize('MANAGER', 'ADMIN'),
  [
    body('name')
      .isString()
      .withMessage('Name must be a string')
      .trim()
      .isLength({ min: 2, max: 150 })
      .withMessage('Name must be between 2 and 150 characters'),
    body('description')
      .optional()
      .isString()
      .isLength({ max: 2000 })
      .withMessage('Description must be at most 2000 characters'),
  ],
  validate,
  createProject
);

// GET /projects — all active users
router.get(
  '/',
  [
    query('status')
      .optional()
      .isIn(['ACTIVE', 'ARCHIVED'])
      .withMessage('Status must be ACTIVE or ARCHIVED'),
  ],
  validate,
  listProjects
);

// GET /projects/candidates — MANAGER or ADMIN only
// MUST be registered BEFORE /:id so "candidates" is not treated as an id
router.get(
  '/candidates',
  authorize('MANAGER', 'ADMIN'),
  [
    query('search')
      .optional()
      .isString()
      .withMessage('Search term must be a string')
      .trim()
      .isLength({ max: 100 })
      .withMessage('Search term must be at most 100 characters'),
  ],
  validate,
  getCandidates
);

// POST /projects/:id/members — ADMIN or MANAGER who is a member
// MUST be registered BEFORE /:id GET
router.post(
  '/:id/members',
  [
    param('id').isUUID().withMessage('Invalid project id'),
    body('userId')
      .exists({ checkFalsy: true })
      .withMessage('User id is required')
      .isUUID()
      .withMessage('User id must be a valid UUID'),
  ],
  validate,
  addMember
);

// GET /projects/:id/tasks — list tasks for a project
// MUST be registered BEFORE /:id GET
router.get(
  '/:id/tasks',
  [
    param('id').isUUID().withMessage('Invalid project id'),
    query('status')
      .optional()
      .isIn(['TODO', 'IN_PROGRESS', 'DONE'])
      .withMessage('Status must be TODO, IN_PROGRESS, or DONE'),
  ],
  validate,
  getProjectTasks
);

// GET /projects/:id — project detail (members + admins)
router.get(
  '/:id',
  [param('id').isUUID().withMessage('Invalid project id')],
  validate,
  getProject
);

// PATCH /projects/:id — update project (ADMIN, or MANAGER who is a member)
router.patch(
  '/:id',
  [
    param('id').isUUID().withMessage('Invalid project id'),
    body('name')
      .optional()
      .isString()
      .withMessage('Name must be a string')
      .trim()
      .isLength({ min: 2, max: 150 })
      .withMessage('Name must be between 2 and 150 characters'),
    body('description')
      .optional()
      .isString()
      .isLength({ max: 2000 })
      .withMessage('Description must be at most 2000 characters'),
    body('status')
      .optional()
      .isIn(['ACTIVE', 'ARCHIVED'])
      .withMessage('Status must be ACTIVE or ARCHIVED'),
  ],
  validate,
  updateProject
);

module.exports = router;
