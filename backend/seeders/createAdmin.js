require('dotenv').config();
const argon2 = require('argon2');
const { sequelize, User } = require('../src/models');

async function createAdmin() {
  try {
    const { ADMIN_NAME, ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;

    // Validate all admin env variables are present
    if (!ADMIN_NAME) {
      console.log('Missing ADMIN_NAME in .env');
      process.exit(1);
    }
    if (!ADMIN_EMAIL) {
      console.log('Missing ADMIN_EMAIL in .env');
      process.exit(1);
    }
    if (!ADMIN_PASSWORD) {
      console.log('Missing ADMIN_PASSWORD in .env');
      process.exit(1);
    }

    // Validate password strength (minimum 8 characters)
    if (ADMIN_PASSWORD.length < 8) {
      console.log('ADMIN_PASSWORD must be at least 8 characters');
      process.exit(1);
    }

    await sequelize.authenticate();
    await sequelize.sync();

    const email = ADMIN_EMAIL.trim().toLowerCase();

    // Check if admin already exists — change nothing
    const existing = await User.findOne({ where: { email } });
    if (existing) {
      console.log('Admin already exists');
      await sequelize.close();
      process.exit(0);
    }

    // Create the admin user
    const passwordHash = await argon2.hash(ADMIN_PASSWORD);
    await User.create({
      name: ADMIN_NAME,
      email,
      passwordHash,
      role: 'ADMIN',
      status: 'ACTIVE',
    });

    console.log(`Admin created: ${email}`);
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.log(`Error: ${error.message}`);
    process.exit(1);
  }
}

createAdmin();