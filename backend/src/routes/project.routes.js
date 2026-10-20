const express = require('express');
const { body, query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize, requireActive } = require('../middleware/authorize');
const { createProject, listProjects } = require('../controllers/project.controller');

const router = express.Router();

// Every route requires authentication + ACTIVE status
router.use(authenticate, requireActive);

// POST /projects — MANAGER or ADMIN only
router.post(
  '/',
  authorize('MANAGER', 'ADMIN'),
  [
    body('name')
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

module.exports = router;