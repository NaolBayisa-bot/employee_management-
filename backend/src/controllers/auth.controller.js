const argon2 = require('argon2');
const { User } = require('../models');
const { signToken } = require('../utils/jwt');

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Normalize email for lookup (trim + lowercase)
    const normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email: normalizedEmail } });
    if (existingUser) {
      return res.status(409).json({ message: 'Email already registered' });
    }

    // Hash password with argon2
    const passwordHash = await argon2.hash(password);

    // Create user — role and status are NEVER set from request body.
    // User model defaults ensure: role = null, status = 'PENDING'.
    const user = await User.create({
      name,
      email: normalizedEmail,
      passwordHash,
    });

    return res.status(201).json({
      message: 'Registration successful. Waiting for admin approval.',
      user,
    });
  } catch (error) {
    // Handle unique constraint race condition (two simultaneous requests)
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({ message: 'Email already registered' });
    }
    throw error;
  }
};

// POST /auth/login — any ACTIVE or PENDING user can log in
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = email.trim().toLowerCase();

    const user = await User.findOne({ where: { email: normalizedEmail } });

    // Same message for user not found and wrong password
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const validPassword = await argon2.verify(user.passwordHash, password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // DEACTIVATED users cannot log in
    if (user.status === 'DEACTIVATED') {
      return res.status(403).json({ message: 'Account deactivated' });
    }

    // ACTIVE and PENDING users receive a token
    const token = signToken(user.id);
    return res.status(200).json({ token, user });
  } catch (error) {
    throw error;
  }
};

// POST /auth/admin/login — only ACTIVE ADMIN users
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = email.trim().toLowerCase();

    const user = await User.findOne({ where: { email: normalizedEmail } });

    // Same 401 message for user not found and wrong password
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const validPassword = await argon2.verify(user.passwordHash, password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Only ACTIVE ADMIN users can access admin endpoints
    if (user.role !== 'ADMIN' || user.status !== 'ACTIVE') {
      return res.status(403).json({ message: 'Admin access only' });
    }

    const token = signToken(user.id);
    return res.status(200).json({ token, user });
  } catch (error) {
    throw error;
  }
};