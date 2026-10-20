const { sequelize, Project, ProjectMember, User } = require('../models');
const { Op } = require('sequelize');

// POST /projects — create a project (MANAGER, ADMIN only)
exports.createProject = async (req, res) => {
  const { name, description } = req.body;
  const userId = req.user.id;

  const project = await sequelize.transaction(async (t) => {
    const project = await Project.create(
      { name, description, ownerId: userId },
      { transaction: t }
    );

    await ProjectMember.create(
      { projectId: project.id, userId: userId },
      { transaction: t }
    );

    return project;
  });

  const memberCount = await ProjectMember.count({
    where: { projectId: project.id },
  });

  const owner = await User.findByPk(project.ownerId, {
    attributes: ['id', 'name'],
  });

  return res.status(201).json({
    project: {
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      owner: owner ? { id: owner.id, name: owner.name } : null,
      memberCount,
      createdAt: project.createdAt,
    },
  });
};

// GET /projects — list projects visible to the authenticated user
exports.listProjects = async (req, res) => {
  const { status } = req.query;
  const userId = req.user.id;

  const where = {};
  if (status) {
    where.status = status;
  }

  // ADMIN sees all projects; MANAGER/EMPLOYEE see only their own
  if (req.user.role !== 'ADMIN') {
    const memberRows = await ProjectMember.findAll({
      where: { userId: userId },
      attributes: ['projectId'],
      raw: true,
    });
    const projectIds = memberRows.map((r) => r.projectId);
    where.id = { [Op.in]: projectIds };
  }

  const projects = await Project.findAll({
    where,
    include: [
      {
        model: User,
        as: 'owner',
        attributes: ['id', 'name'],
      },
    ],
    order: [['createdAt', 'DESC']],
  });

  // Single GROUP BY query for member counts (avoids loading all member rows)
  const allProjectIds = projects.map((p) => p.id);
  const memberCountRows = allProjectIds.length
    ? await ProjectMember.findAll({
        where: { projectId: { [Op.in]: allProjectIds } },
        attributes: ['projectId', [sequelize.fn('COUNT', sequelize.col('projectId')), 'count']],
        group: 'projectId',
        raw: true,
      })
    : [];

  const memberCountMap = {};
  memberCountRows.forEach((row) => {
    memberCountMap[row.projectId] = parseInt(row.count, 10);
  });

  const result = projects.map((project) => ({
    id: project.id,
    name: project.name,
    description: project.description,
    status: project.status,
    owner: project.owner ? { id: project.owner.id, name: project.owner.name } : null,
    memberCount: memberCountMap[project.id] || 0,
    taskCount: 0, // No Task model exists yet
    createdAt: project.createdAt,
  }));

  return res.status(200).json({ projects: result });
};