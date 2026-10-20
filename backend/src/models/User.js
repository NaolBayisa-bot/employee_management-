const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const User = sequelize.define(
  'User',
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      // Trim whitespace before saving
      set(value) {
        this.setDataValue('name', value.trim());
      },
      validate: {
        len: { args: [2, 100], msg: 'Name must be between 2 and 100 characters' },
      },
    },
    email: {
      type: DataTypes.STRING(150),
      allowNull: false,
      unique: true,
      // Store trimmed and lowercase
      set(value) {
        this.setDataValue('email', value.trim().toLowerCase());
      },
      validate: {
        isEmail: { msg: 'Must be a valid email address' },
      },
    },
    passwordHash: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    role: {
      type: DataTypes.ENUM('ADMIN', 'MANAGER', 'EMPLOYEE'),
      allowNull: true,
      defaultValue: null,
    },
    status: {
      type: DataTypes.ENUM('PENDING', 'ACTIVE', 'DEACTIVATED'),
      allowNull: false,
      defaultValue: 'PENDING',
    },
  },
  {
    tableName: 'users',
    timestamps: true,
    indexes: [{ fields: ['status'] }],
  }
);

// Always exclude passwordHash and updatedAt from serialized output
User.prototype.toJSON = function () {
  return {
    id: this.id,
    name: this.name,
    email: this.email,
    role: this.role,
    status: this.status,
    createdAt: this.createdAt,
  };
};

module.exports = User;