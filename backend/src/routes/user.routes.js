const express = require('express');
const { body, param, query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize } = require('../middleware/authorize');
const { listUsers, approveUser, changeRole, deactivateUser, reactivateUser } = require('../controllers/user.controller');

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

// PATCH /users/:id/role — change role of an ACTIVE user
router.patch(
  '/:id/role',
  [
    param('id').isUUID().withMessage('Invalid user id'),
    body('role')
      .isIn(['MANAGER', 'EMPLOYEE'])
      .withMessage('Role must be MANAGER or EMPLOYEE'),
  ],
  validate,
  changeRole
);

// PATCH /users/:id/deactivate — deactivate an ACTIVE or PENDING user
router.patch(
  '/:id/deactivate',
  [param('id').isUUID().withMessage('Invalid user id')],
  validate,
  deactivateUser
);

// PATCH /users/:id/reactivate — reactivate a DEACTIVATED user with a role
router.patch(
  '/:id/reactivate',
  [param('id').isUUID().withMessage('Invalid user id')],
  validate,
  reactivateUser
);

module.exports = router;