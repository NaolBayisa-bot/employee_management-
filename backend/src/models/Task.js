const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Task = sequelize.define(
  'Task',
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    title: {
      type: DataTypes.STRING(200),
      allowNull: false,
      set(value) {
        this.setDataValue('title', value.trim());
      },
      validate: {
        len: { args: [2, 200], msg: 'Title must be between 2 and 200 characters' },
      },
    },
    description: {
      type: DataTypes.STRING(5000),
      allowNull: true,
    },
    projectId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'projects', key: 'id' },
    },
    assigneeId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'users', key: 'id' },
    },
    createdById: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'users', key: 'id' },
    },
    priority: {
      type: DataTypes.ENUM('LOW', 'MEDIUM', 'HIGH'),
      allowNull: false,
      defaultValue: 'MEDIUM',
    },
    dueDate: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    status: {
      type: DataTypes.ENUM('TODO', 'IN_PROGRESS', 'DONE'),
      allowNull: false,
      defaultValue: 'TODO',
    },
  },
  {
    tableName: 'tasks',
    timestamps: true,
    indexes: [
      { fields: ['projectId'] },
      { fields: ['assigneeId', 'status'] },
    ],
  }
);

module.exports = Task;