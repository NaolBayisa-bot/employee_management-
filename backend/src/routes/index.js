const express = require('express');
const router = express.Router();
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');

// Mount auth routes under /auth
router.use('/auth', authRoutes);

// Mount user management routes under /users (admin only)
router.use('/users', userRoutes);

module.exports = router;