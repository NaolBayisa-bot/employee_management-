const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Project = sequelize.define(
  'Project',
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    name: {
      type: DataTypes.STRING(150),
      allowNull: false,
      set(value) {
        this.setDataValue('name', value.trim());
      },
      validate: {
        len: { args: [2, 150], msg: 'Name must be between 2 and 150 characters' },
      },
    },
    description: {
      type: DataTypes.STRING(2000),
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM('ACTIVE', 'ARCHIVED'),
      allowNull: false,
      defaultValue: 'ACTIVE',
    },
    ownerId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
    },
  },
  {
    tableName: 'projects',
    timestamps: true,
    indexes: [{ fields: ['ownerId'] }],
  }
);

module.exports = Project;