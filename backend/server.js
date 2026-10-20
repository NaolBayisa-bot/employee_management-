require('dotenv').config();

// Validate JWT_SECRET at startup — must exist and be at least 32 characters
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
  console.error('FATAL: JWT_SECRET is missing or shorter than 32 characters');
  process.exit(1);
}

const app = require('./src/app');
const { sequelize } = require('./src/models');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    await sequelize.authenticate();
    console.log('Database connected');

    // sync() is for development only
    await sequelize.sync();
    console.log('Models synced');

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.log(`Database connection failed: ${error.message}`);
    process.exit(1);
  }
}

startServer();