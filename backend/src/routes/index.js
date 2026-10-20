const express = require('express');
const router = express.Router();
const authRoutes = require('./auth.routes');
const userRoutes = require('./user.routes');
const projectRoutes = require('./project.routes');
const taskRoutes = require('./task.routes');

// Mount auth routes under /auth
router.use('/auth', authRoutes);

// Mount user management routes under /users (admin only)
router.use('/users', userRoutes);

// Mount project routes under /projects
router.use('/projects', projectRoutes);

// Mount task routes under /tasks
router.use('/tasks', taskRoutes);

module.exports = router;