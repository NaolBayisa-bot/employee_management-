const express = require('express');
const { query } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize } = require('../middleware/authorize');
const { asyncHandler } = require('../middleware/errorHandler');
const { ACTIONS } = require('../services/activityLog');
const { getActivity } = require('../controllers/activity.controller');

const router = express.Router();

// All activity routes: ADMIN only
router.use(authenticate, authorize('ADMIN'));

router.get(
  '/',
  [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be an integer >= 1'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be an integer between 1 and 100'),
    query('userId')
      .optional()
      .isUUID()
      .withMessage('userId must be a valid UUID'),
    query('action')
      .optional()
      .isIn(Object.values(ACTIONS))
      .withMessage('action must be a valid action'),
    query('entityType')
      .optional()
      .isIn(['USER', 'PROJECT', 'TASK'])
      .withMessage('entityType must be USER, PROJECT, or TASK'),
    query('projectId')
      .optional()
      .isUUID()
      .withMessage('projectId must be a valid UUID'),
    query('from')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('from must be a valid ISO8601 date'),
    query('to')
      .optional()
      .isISO8601({ strict: true })
      .withMessage('to must be a valid ISO8601 date'),
  ],
  validate,
  asyncHandler(getActivity)
);

module.exports = router;
