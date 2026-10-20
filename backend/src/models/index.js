const sequelize = require('../config/db');
const User = require('./User');
const Project = require('./Project');
const ProjectMember = require('./ProjectMember');
const Task = require('./Task');
const ActivityLog = require('./ActivityLog');

// User ↔ Project (owner) relationships
User.hasMany(Project, { foreignKey: 'ownerId', as: 'ownedProjects' });
Project.belongsTo(User, { foreignKey: 'ownerId', as: 'owner' });

// User ↔ Project (many-to-many via ProjectMember)
User.belongsToMany(Project, {
  through: ProjectMember,
  foreignKey: 'userId',
  otherKey: 'projectId',
  as: 'projects',
});
Project.belongsToMany(User, {
  through: ProjectMember,
  foreignKey: 'projectId',
  otherKey: 'userId',
  as: 'members',
});

// Join table associations (CASCADE on delete)
ProjectMember.belongsTo(Project, { foreignKey: 'projectId', onDelete: 'CASCADE' });
ProjectMember.belongsTo(User, { foreignKey: 'userId', onDelete: 'CASCADE' });

// Project ↔ Task relationships
Project.hasMany(Task, { foreignKey: 'projectId', as: 'tasks' });
Task.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });

// Task ↔ User (assignee) — SET NULL on delete
Task.belongsTo(User, {
  foreignKey: 'assigneeId',
  as: 'assignee',
  onDelete: 'SET NULL',
});
User.hasMany(Task, { foreignKey: 'assigneeId', as: 'assignedTasks' });

// Task ↔ User (creator)
Task.belongsTo(User, {
  foreignKey: 'createdById',
  as: 'createdBy',
});

// ActivityLog associations
ActivityLog.belongsTo(User, { foreignKey: 'actorId', as: 'actor' });
User.hasMany(ActivityLog, { foreignKey: 'actorId', as: 'activities' });

module.exports = {
  sequelize,
  User,
  Project,
  ProjectMember,
  Task,
  ActivityLog,
};
