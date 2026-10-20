const { Sequelize } = require('sequelize');

// Build Sequelize instance from env variables.
// dotenv.config() is called in server.js before this module is loaded,
// so process.env values are available here.

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false,
    define: {
      underscored: false, // keep camelCase columns
    },
  }
);

module.exports = sequelize;