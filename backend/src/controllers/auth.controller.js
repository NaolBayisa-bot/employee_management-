const argon2 = require('argon2');
const { User } = require('../models');

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