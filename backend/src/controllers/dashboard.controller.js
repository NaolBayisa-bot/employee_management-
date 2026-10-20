const { Op } = require('sequelize');
const { User, Project, Task } = require('../models');

/**
 * GET /dashboard/stats
 * Returns aggregate counts for the admin dashboard.
 * Uses COUNT queries only — never loads full tables.
 */
exports.getStats = async (req, res) => {
  const [
    totalUsers,
    pendingUsers,
    activeProjects,
    openTasks,
    doneTasks,
    todoCount,
    inProgressCount,
  ] = await Promise.all([
    User.count({ where: { status: 'ACTIVE' } }),
    User.count({ where: { status: 'PENDING' } }),
    Project.count({ where: { status: 'ACTIVE' } }),
    Task.count({
      where: { status: { [Op.in]: ['TODO', 'IN_PROGRESS'] } },
    }),
    Task.count({ where: { status: 'DONE' } }),
    Task.count({ where: { status: 'TODO' } }),
    Task.count({ where: { status: 'IN_PROGRESS' } }),
  ]);

  return res.status(200).json({
    totalUsers,
    pendingUsers,
    activeProjects,
    openTasks,
    doneTasks,
    tasksByStatus: {
      TODO: todoCount,
      IN_PROGRESS: inProgressCount,
      DONE: doneTasks,
    },
  });
};
