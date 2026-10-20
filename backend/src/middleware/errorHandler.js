/**
 * Central error handling middleware.
 *
 * asyncHandler — wraps async route handlers so rejected promises reach express
 *               error handling (required for Express 4; harmless on Express 5).
 * notFound    — 404 for unknown routes. Register AFTER all routes.
 * errorHandler — global error handler. Register LAST.
 */

// Wrap an async function so rejected promises call next(err)
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Catch-all for unmatched routes
const notFound = (req, res) => {
  res.status(404).json({ message: 'Route not found' });
};

// Global error handler — never leaks internals to the client
const errorHandler = (err, req, res, next) => {
  // Log full error on the server side
  console.error('Error:', err);

  // Malformed JSON body
  if (err.type === 'entity.parse.failed' && err.status === 400) {
    return res.status(400).json({ message: 'Invalid JSON' });
  }

  // Request body exceeds the 100kb limit
  if (err.type === 'entity.too.large') {
    return res.status(413).json({ message: 'Request entity too large' });
  }

  // Sequelize unique constraint violation → 409
  if (err.name === 'SequelizeUniqueConstraintError') {
    const field = Object.keys(err.errors)[0];
    const message = err.errors[field]?.message || 'Duplicate value';
    return res.status(409).json({ message });
  }

  // Sequelize model validation failure → 400
  if (err.name === 'SequelizeValidationError') {
    return res.status(400).json({
      message: 'Validation failed',
      errors: err.errors.map((e) => ({
        field: e.path,
        message: e.message,
      })),
    });
  }

  // Fallback — don't leak stack traces or SQL
  res.status(err.status || 500).json({
    message: err.status ? err.message : 'Internal server error',
  });
};

module.exports = { asyncHandler, notFound, errorHandler };
