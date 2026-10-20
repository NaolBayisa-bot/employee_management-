

const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const { notFound, errorHandler } = require('./middleware/errorHandler');

const app = express();

// Disable X-Powered-By header (information disclosure protection)
app.disable('x-powered-by');

// Configurable CORS origin (comma-separated list, default "*" for development)
const corsOrigin = process.env.CORS_ORIGIN || '*';
app.use(cors({ origin: corsOrigin === '*' ? '*' : corsOrigin.split(',') }));
app.use(express.json({ limit: '100kb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// API routes
app.use(routes);

// 404 handler — must be after all routes
app.use(notFound);

// Global error handler — must be last
app.use(errorHandler);

module.exports = app;