const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const ProjectMember = sequelize.define(
  'ProjectMember',
  {
    projectId: {
      type: DataTypes.UUID,
      primaryKey: true,
      references: { model: 'projects', key: 'id' },
    },
    userId: {
      type: DataTypes.UUID,
      primaryKey: true,
    },
  },
  {
    tableName: 'project_members',
    timestamps: false,
    indexes: [
      { unique: true, fields: ['projectId', 'userId'] },
      { fields: ['userId'] },
    ],
  }
);

module.exports = ProjectMember;