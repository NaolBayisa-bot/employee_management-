const { verifyToken } = require('../utils/jwt');
const { User } = require('../models');

// Middleware: protects routes with JWT authentication.
// Loads the user from the database on EVERY request so deactivation
// and role changes apply immediately, even with an old token.
const authenticate = async (req, res, next) => {
  try {
    // Read Authorization header: expected format "Bearer <token>"
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    const token = authHeader.substring(7); // Remove "Bearer " prefix

    // Verify token — catches invalid, tampered, or expired tokens
    let payload;
    try {
      payload = verifyToken(token);
    } catch (error) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Load user from database by id (fresh from DB on every request)
    const user = await User.findByPk(payload.id);
    if (!user) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // DEACTIVATED users are blocked
    if (user.status === 'DEACTIVATED') {
      return res.status(403).json({ message: 'Account deactivated' });
    }

    // Set req.user and proceed.
    // PENDING users ARE allowed through this middleware — they just
    // can't use business endpoints (handled by authorize middleware later).
    req.user = user;
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = authenticate;