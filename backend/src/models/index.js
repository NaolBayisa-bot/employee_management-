const sequelize = require('../config/db');
const User = require('./User');
const Project = require('./Project');
const ProjectMember = require('./ProjectMember');

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

module.exports = {
  sequelize,
  User,
  Project,
  ProjectMember,
};