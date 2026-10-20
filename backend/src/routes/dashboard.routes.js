const express = require('express');
const authenticate = require('../middleware/authenticate');
const { authorize } = require('../middleware/authorize');
const { getStats } = require('../controllers/dashboard.controller');

const router = express.Router();

// All dashboard routes: ADMIN only
router.use(authenticate, authorize('ADMIN'));

router.get('/stats', getStats);

module.exports = router;
