const { Op } = require('sequelize');
const { User } = require('../models');

// GET /users — list users with optional status and search filters
exports.listUsers = async (req, res) => {
  const { status, search } = req.query;

  const where = {};
  if (status) {
    where.status = status;
  }
  if (search) {
    // Case-insensitive search on name and email
    where[Op.or] = [
      { name: { [Op.iLike]: `%${search}%` } },
      { email: { [Op.iLike]: `%${search}%` } },
    ];
  }

  const users = await User.findAll({
    where,
    order: [['createdAt', 'DESC']],
  });

  return res.status(200).json({ users });
};

// PATCH /users/:id/approve — approve a PENDING user
exports.approveUser = async (req, res) => {
  const { id } = req.params;
  const { role } = req.body;

  // User must exist
  const user = await User.findByPk(id);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  // User must be PENDING
  if (user.status !== 'PENDING') {
    return res.status(400).json({ message: 'User is not pending' });
  }

  // Cannot target self or any existing ADMIN
  if (user.id === req.user.id || user.role === 'ADMIN') {
    return res.status(403).json({ message: 'Forbidden' });
  }

  // Set role and status ACTIVE
  user.role = role;
  user.status = 'ACTIVE';
  await user.save();

  return res.status(200).json({ user });
};