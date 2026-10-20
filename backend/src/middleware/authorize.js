/**
 * authorize(...allowedRoles)
 * Used AFTER authenticate. Returns 403 unless user is ACTIVE and has an allowed role.
 * If req.user is missing, returns 401 (defensive check — authenticate should run first).
 */
const authorize = (...allowedRoles) => {
  return (req, res, next) => {
    // Defensive: authenticate should have set req.user
    if (!req.user) {
      return res.status(401).json({ message: 'Authentication required' });
    }

    // Must be ACTIVE status
    if (req.user.status !== 'ACTIVE') {
      return res.status(403).json({ message: 'Forbidden' });
    }

    // Must have an allowed role
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    next();
  };
};

/**
 * requireActive — checks only status ACTIVE (any role).
 * Business routes for all roles will use this.
 */
const requireActive = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  if (req.user.status !== 'ACTIVE') {
    return res.status(403).json({ message: 'Forbidden' });
  }

  next();
};

module.exports = { authorize, requireActive };