const { Op } = require('sequelize');
const { User } = require('../models');
const { ACTIONS, log } = require('../services/activityLog');

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

  // Safety: cannot target self (400)
  if (user.id === req.user.id) {
    return res.status(400).json({ message: 'You cannot modify your own account' });
  }

  // Safety: cannot modify ADMIN accounts (403)
  if (user.role === 'ADMIN') {
    return res.status(403).json({ message: 'Admin accounts cannot be modified' });
  }

  // User must be PENDING
  if (user.status !== 'PENDING') {
    return res.status(400).json({ message: 'User is not pending' });
  }

  // Set role and status ACTIVE
  user.role = role;
  user.status = 'ACTIVE';
  await user.save();

  await log({
    actorId: req.user.id,
    action: ACTIONS.USER_APPROVED,
    entityType: 'USER',
    entityId: user.id,
    meta: { userName: user.name, role: user.role },
  });

  return res.status(200).json({ user });
};

// PATCH /users/:id/role — change role of an ACTIVE user
exports.changeRole = async (req, res) => {
  const { id } = req.params;
  const { role } = req.body;

  const user = await User.findByPk(id);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  // Safety: cannot target self
  if (user.id === req.user.id) {
    return res.status(400).json({ message: 'You cannot modify your own account' });
  }

  // Safety: cannot modify ADMIN accounts
  if (user.role === 'ADMIN') {
    return res.status(403).json({ message: 'Admin accounts cannot be modified' });
  }

  // Target must be ACTIVE
  if (user.status !== 'ACTIVE') {
    return res.status(400).json({ message: 'User must be ACTIVE' });
  }

  const oldRole = user.role;
  user.role = role;
  await user.save();

  await log({
    actorId: req.user.id,
    action: ACTIONS.USER_ROLE_CHANGED,
    entityType: 'USER',
    entityId: user.id,
    meta: { userName: user.name, from: oldRole, to: role },
  });

  return res.status(200).json({ user });
};

// PATCH /users/:id/deactivate — deactivate an ACTIVE or PENDING user
exports.deactivateUser = async (req, res) => {
  const { id } = req.params;

  const user = await User.findByPk(id);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  // Safety: cannot target self
  if (user.id === req.user.id) {
    return res.status(400).json({ message: 'You cannot modify your own account' });
  }

  // Safety: cannot modify ADMIN accounts
  if (user.role === 'ADMIN') {
    return res.status(403).json({ message: 'Admin accounts cannot be modified' });
  }

  // Target must be ACTIVE or PENDING
  if (user.status === 'DEACTIVATED') {
    return res.status(400).json({ message: 'Already deactivated' });
  }

  user.status = 'DEACTIVATED';
  await user.save();

  await log({
    actorId: req.user.id,
    action: ACTIONS.USER_DEACTIVATED,
    entityType: 'USER',
    entityId: user.id,
    meta: { userName: user.name },
  });

  return res.status(200).json({ user });
};

// PATCH /users/:id/reactivate — reactivate a DEACTIVATED user with a role
exports.reactivateUser = async (req, res) => {
  const { id } = req.params;

  const user = await User.findByPk(id);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  // Safety: cannot target self
  if (user.id === req.user.id) {
    return res.status(400).json({ message: 'You cannot modify your own account' });
  }

  // Safety: cannot modify ADMIN accounts
  if (user.role === 'ADMIN') {
    return res.status(403).json({ message: 'Admin accounts cannot be modified' });
  }

  // Target must be DEACTIVATED and have a role
  if (user.status !== 'DEACTIVATED' || user.role === null) {
    return res.status(400).json({ message: 'User was never approved, approve them instead' });
  }

  user.status = 'ACTIVE';
  await user.save();

  await log({
    actorId: req.user.id,
    action: ACTIONS.USER_REACTIVATED,
    entityType: 'USER',
    entityId: user.id,
    meta: { userName: user.name },
  });

  return res.status(200).json({ user });
};
