const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const authenticate = require('../middleware/authenticate');
const { authorize } = require('../middleware/authorize');
const { register, login, adminLogin, me } = require('../controllers/auth.controller');

const router = express.Router();

router.post(
  '/register',
  [
    body('name')
      .exists({ checkFalsy: true })
      .withMessage('Name is required')
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),
    body('email')
      .trim()
      .isEmail()
      .withMessage('Must be a valid email address')
      .normalizeEmail({ gmail_removeDots: false }),
    body('password')
      .exists({ checkFalsy: true })
      .withMessage('Password is required')
      .isString()
      .isLength({ min: 8, max: 72 })
      .withMessage('Password must be between 8 and 72 characters'),
  ],
  validate,
  register
);

router.post(
  '/login',
  [
    body('email')
      .trim()
      .isEmail()
      .withMessage('Must be a valid email address')
      .normalizeEmail({ gmail_removeDots: false }),
    body('password')
      .exists({ checkFalsy: true })
      .withMessage('Password is required')
      .isString(),
  ],
  validate,
  login
);

router.post(
  '/admin/login',
  [
    body('email')
      .trim()
      .isEmail()
      .withMessage('Must be a valid email address')
      .normalizeEmail({ gmail_removeDots: false }),
    body('password')
      .exists({ checkFalsy: true })
      .withMessage('Password is required')
      .isString(),
  ],
  validate,
  adminLogin
);

// GET /auth/me — protected by authenticate middleware
router.get('/me', authenticate, me);

// TEMPORARY: remove in Task 10
router.get('/admin-check', authenticate, authorize('ADMIN'), (req, res) => {
  res.status(200).json({ ok: true });
});

module.exports = router;