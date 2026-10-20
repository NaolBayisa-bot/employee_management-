const { sequelize, Project, ProjectMember, User } = require('../models');
const { Op } = require('sequelize');
const { ACTIONS, log } = require('../services/activityLog');

// Helper: check if a user is a member of a project
async function isProjectMember(userId, projectId) {
  const membership = await ProjectMember.findOne({
    where: { userId, projectId },
  });
  return !!membership;
}
exports.isProjectMember = isProjectMember;

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

  await log({
    actorId: req.user.id,
    action: ACTIONS.PROJECT_CREATED,
    entityType: 'PROJECT',
    entityId: project.id,
    projectId: project.id,
    meta: { projectName: project.name },
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


// PATCH /projects/:id — update a project (ADMIN, or MANAGER who is a member)
exports.updateProject = async (req, res) => {
  const { id } = req.params;
  const { name, description, status } = req.body;

  const project = await Project.findByPk(id);
  if (!project) {
    return res.status(404).json({ message: 'Project not found' });
  }

  // ADMIN can update any project; MANAGER must be a member
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, id);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  // Capture old values before modification
  const oldName = project.name;
  const oldDescription = project.description;
  const oldStatus = project.status;

  if (name !== undefined) project.name = name;
  if (description !== undefined) project.description = description;
  if (status !== undefined) project.status = status;

  await project.save();

  // Log only if something actually changed
  const changedFields = [];
  if (name !== undefined && name !== oldName) changedFields.push('name');
  if (description !== undefined && description !== oldDescription) changedFields.push('description');
  if (status !== undefined && status !== oldStatus) changedFields.push('status');

  if (changedFields.length > 0) {
    const meta = { projectName: project.name, changes: changedFields };
    if (status !== undefined && status !== oldStatus) {
      meta.from = oldStatus;
      meta.to = status;
    }
    await log({
      actorId: req.user.id,
      action: ACTIONS.PROJECT_UPDATED,
      entityType: 'PROJECT',
      entityId: project.id,
      projectId: project.id,
      meta,
    });
  }

  const owner = await User.findByPk(project.ownerId, {
    attributes: ['id', 'name'],
  });

  return res.status(200).json({
    project: {
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      owner: owner ? { id: owner.id, name: owner.name } : null,
      createdAt: project.createdAt,
    },
  });
};

// POST /projects/:id/members — add a member (ADMIN, or MANAGER who is a member)
exports.addMember = async (req, res) => {
  const { id } = req.params; // projectId
  const { userId } = req.body;

  const project = await Project.findByPk(id);
  if (!project) {
    return res.status(404).json({ message: 'Project not found' });
  }

  // ADMIN can add to any project; MANAGER must be a member
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, id);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  // Project must not be ARCHIVED
  if (project.status === 'ARCHIVED') {
    return res.status(400).json({ message: 'Cannot add members to an archived project' });
  }

  // Target user must exist and be ACTIVE with role MANAGER or EMPLOYEE
  const targetUser = await User.findByPk(userId);
  if (!targetUser) {
    return res.status(400).json({ message: 'User not found' });
  }
  if (targetUser.status !== 'ACTIVE') {
    return res.status(400).json({ message: 'User must be ACTIVE to be added as a member' });
  }
  if (targetUser.role !== 'MANAGER' && targetUser.role !== 'EMPLOYEE') {
    return res.status(400).json({ message: 'User must have a role of MANAGER or EMPLOYEE' });
  }

  // Check if already a member
  const existing = await ProjectMember.findOne({
    where: { projectId: id, userId: userId },
  });
  if (existing) {
    return res.status(409).json({ message: 'User is already a member of this project' });
  }

  // Add as member
  await ProjectMember.create({ projectId: id, userId: userId });

  await log({
    actorId: req.user.id,
    action: ACTIONS.MEMBER_ADDED,
    entityType: 'PROJECT',
    entityId: project.id,
    projectId: project.id,
    meta: { projectName: project.name, userName: targetUser.name },
  });

  // Fetch updated member list (only id, name, role)
  const projectWithMembers = await Project.findByPk(id, {
    include: [
      {
        model: User,
        as: 'members',
        attributes: ['id', 'name', 'role'],
      },
    ],
  });

  const members = projectWithMembers.members
    ? projectWithMembers.members.map((m) => ({
        id: m.id,
        name: m.name,
        role: m.role,
      }))
    : [];

  return res.status(201).json({ members });
};
exports.getCandidates = async (req, res) => {
  const { search } = req.query;

  const where = {
    status: 'ACTIVE',
    role: { [Op.in]: ['MANAGER', 'EMPLOYEE'] },
  };

  if (search) {
    where.name = { [Op.iLike]: `%${search}%` };
  }

  const users = await User.findAll({
    where,
    attributes: ['id', 'name', 'role'],
    order: [['name', 'ASC']],
  });

  return res.status(200).json({ users });
};

// GET /projects/:id — project detail (members + admins)
exports.getProject = async (req, res) => {
  const { id } = req.params;

  const project = await Project.findByPk(id, {
    include: [
      { model: User, as: 'owner', attributes: ['id', 'name'] },
      { model: User, as: 'members', attributes: ['id', 'name', 'role'] },
    ],
  });

  if (!project) {
    return res.status(404).json({ message: 'Project not found' });
  }

  // ADMIN can access any project; others must be a member
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, id);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  return res.status(200).json({
    project: {
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      owner: project.owner ? { id: project.owner.id, name: project.owner.name } : null,
      members: project.members
        ? project.members.map((m) => ({ id: m.id, name: m.name, role: m.role }))
        : [],
      createdAt: project.createdAt,
    },
  });
};