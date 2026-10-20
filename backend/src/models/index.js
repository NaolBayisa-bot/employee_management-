const sequelize = require('../config/db');
const User = require('./User');

// Initialize all models here as they are created.
// Each model imports the sequelize instance directly from ../config/db.

module.exports = {
  sequelize,
  User,
};