const { validationResult } = require('express-validator');

// Middleware: runs after express-validator chains.
// If validation errors exist, respond 400 with structured error format.
// Otherwise, call next().
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
      })),
    });
  }
  next();
};

module.exports = validate;