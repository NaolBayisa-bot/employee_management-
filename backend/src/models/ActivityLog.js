const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const ActivityLog = sequelize.define(
  'ActivityLog',
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    actorId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
    },
    action: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    entityType: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    entityId: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    projectId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'projects', key: 'id' },
    },
    meta: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {},
    },
  },
  {
    tableName: 'activity_logs',
    timestamps: true,
    updatedAt: false,
    indexes: [
      { fields: ['createdAt'] },
      { fields: ['actorId'] },
      { fields: ['action'] },
    ],
  }
);

module.exports = ActivityLog;
