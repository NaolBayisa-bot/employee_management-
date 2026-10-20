const rateLimit = require('express-rate-limit');

// Configurable rate limits via environment variables.
// Defaults: login 10 per 15 min, register 10 per hour.
const loginMax = parseInt(process.env.AUTH_LOGIN_MAX) || 10;
const loginWindowMs = parseInt(process.env.AUTH_LOGIN_WINDOW_MS) || 15 * 60 * 1000;
const registerMax = parseInt(process.env.AUTH_REGISTER_MAX) || 10;
const registerWindowMs = parseInt(process.env.AUTH_REGISTER_WINDOW_MS) || 60 * 60 * 1000;

// POST /auth/login and POST /auth/admin/login — 10 attempts per 15 min per IP
const loginRateLimiter = rateLimit({
  windowMs: loginWindowMs,
  max: loginMax,
  message: { message: 'Too many attempts, please try again later' },
  statusCode: 429,
  standardHeaders: true,
  legacyHeaders: false,
});

// POST /auth/register — 10 attempts per hour per IP
const registerRateLimiter = rateLimit({
  windowMs: registerWindowMs,
  max: registerMax,
  message: { message: 'Too many attempts, please try again later' },
  statusCode: 429,
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = { loginRateLimiter, registerRateLimiter };
