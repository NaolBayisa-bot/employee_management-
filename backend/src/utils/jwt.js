const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;

// Sign a token with { id } payload only — no role or status in JWT
function signToken(userId) {
  return jwt.sign({ id: userId }, JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
}

// Verify and return decoded token payload
function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

module.exports = { signToken, verifyToken };