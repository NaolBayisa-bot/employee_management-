const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize } = require('../middleware/authorize');
const { listUsers, approveUser } = require('../controllers/user.controller');

const router = express.Router();

// EVERY route in this file requires ADMIN authentication
router.use(authenticate, authorize('ADMIN'));

// GET /users — list users with optional status and search filters
router.get(
  '/',
  [
    query('status')
      .optional()
      .isIn(['PENDING', 'ACTIVE', 'DEACTIVATED'])
      .withMessage('Status must be PENDING, ACTIVE, or DEACTIVATED'),
    query('search')
      .optional()
      .trim()
      .isLength({ max: 100 })
      .withMessage('Search term must be at most 100 characters'),
  ],
  validate,
  listUsers
);

// PATCH /users/:id/approve — approve a PENDING user
router.patch(
  '/:id/approve',
  [
    param('id').isUUID().withMessage('Invalid user id'),
    body('role')
      .isIn(['MANAGER', 'EMPLOYEE'])
      .withMessage('Role must be MANAGER or EMPLOYEE'),
  ],
  validate,
  approveUser
);

module.exports = router;