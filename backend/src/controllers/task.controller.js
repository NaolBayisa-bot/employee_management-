const { sequelize, Project, ProjectMember, Task, User } = require('../models');
const { isProjectMember } = require('./project.controller');

// POST /tasks — create a task (MANAGER, ADMIN only)
exports.createTask = async (req, res) => {
  const { title, description, projectId, assigneeId, dueDate, priority } = req.body;
  const userId = req.user.id;

  // Project must exist
  const project = await Project.findByPk(projectId);
  if (!project) {
    return res.status(404).json({ message: 'Project not found' });
  }

  // Manager must be a member of the project (ADMIN can use any project)
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, projectId);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  // Project must be ACTIVE (not archived)
  if (project.status !== 'ACTIVE') {
    return res.status(400).json({ message: 'Cannot create tasks in an archived project' });
  }

  // If assigneeId is given, user must exist, be ACTIVE, and be a member of the project
  if (assigneeId) {
    const assignee = await User.findByPk(assigneeId);
    if (!assignee) {
      return res.status(400).json({ message: 'User not found' });
    }
    if (assignee.status !== 'ACTIVE') {
      return res.status(400).json({ message: 'Assignee must be an active member of the project' });
    }
    const isAssigneeMember = await ProjectMember.findOne({
      where: { projectId, userId: assigneeId },
    });
    if (!isAssigneeMember) {
      return res.status(400).json({ message: 'Assignee must be an active member of the project' });
    }
  }

  // Create task — createdById = req.user.id, status = 'TODO', priority defaults to 'MEDIUM'
  const task = await Task.create({
    title,
    description,
    projectId,
    assigneeId,
    dueDate,
    priority: priority || 'MEDIUM',
    createdById: userId,
    status: 'TODO',
  });

  // Reuse the project we already loaded for owner info
  const [assignee, createdBy] = await Promise.all([
    assigneeId ? User.findByPk(assigneeId, { attributes: ['id', 'name'] }) : null,
    User.findByPk(userId, { attributes: ['id', 'name'] }),
  ]);

  return res.status(201).json({
    task: {
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      project: { id: project.id, name: project.name },
      assignee: assignee ? { id: assignee.id, name: assignee.name } : null,
      createdBy: createdBy ? { id: createdBy.id, name: createdBy.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    },
  });
};

// GET /tasks/my — list tasks assigned to the current user
exports.getMyTasks = async (req, res) => {
  const { status } = req.query;
  const userId = req.user.id;

  const where = { assigneeId: userId };
  if (status) {
    where.status = status;
  }

  const tasks = await Task.findAll({
    where,
    include: [
      {
        model: Project,
        as: 'project',
        attributes: ['id', 'name'],
      },
    ],
    order: [
      // dueDate ASC with nulls last
      [sequelize.literal('"dueDate" ASC NULLS LAST')],
      // priority HIGH first (1=HIGH, 2=MEDIUM, 3=LOW)
      [sequelize.literal("CASE \"priority\" WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 END ASC")],
      // createdAt DESC
      ['createdAt', 'DESC'],
    ],
  });

  return res.status(200).json({
    tasks: tasks.map((task) => ({
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      project: task.project ? { id: task.project.id, name: task.project.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    })),
  });
};
// GET /projects/:id/tasks — list tasks for a project (called from project.routes.js)
exports.getProjectTasks = async (req, res) => {
  const { id } = req.params; // projectId
  const { status } = req.query;

  const project = await Project.findByPk(id);
  if (!project) {
    return res.status(404).json({ message: 'Project not found' });
  }

  // Allowed for members and ADMIN
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, id);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  const where = { projectId: id };
  if (status) {
    where.status = status;
  }

  const tasks = await Task.findAll({
    where,
    include: [
      {
        model: User,
        as: 'assignee',
        attributes: ['id', 'name'],
      },
    ],
    order: [['createdAt', 'DESC']],
  });

  return res.status(200).json({
    tasks: tasks.map((task) => ({
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      assignee: task.assignee ? { id: task.assignee.id, name: task.assignee.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    })),
  });
};

// GET /tasks/:id — task detail (project, assignee, createdBy)
exports.getTask = async (req, res) => {
  const { id } = req.params;

  const task = await Task.findByPk(id, {
    include: [
      { model: Project, as: 'project', attributes: ['id', 'name'] },
      { model: User, as: 'assignee', attributes: ['id', 'name'] },
      { model: User, as: 'createdBy', attributes: ['id', 'name'] },
    ],
  });

  if (!task) {
    return res.status(404).json({ message: 'Task not found' });
  }

  // Allowed for members of task's project and ADMIN
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, task.projectId);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  return res.status(200).json({
    task: {
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      project: task.project ? { id: task.project.id, name: task.project.name } : null,
      assignee: task.assignee ? { id: task.assignee.id, name: task.assignee.name } : null,
      createdBy: task.createdBy ? { id: task.createdBy.id, name: task.createdBy.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    },
  });
};

// PATCH /tasks/:id — update task (authorize MANAGER, ADMIN only)
exports.updateTask = async (req, res) => {
  const { id } = req.params;
  const { title, description, dueDate, priority, assigneeId } = req.body;

  const task = await Task.findByPk(id);
  if (!task) {
    return res.status(404).json({ message: 'Task not found' });
  }

  // authorize(MANAGER, ADMIN) already applied via the route middleware,
  // but we also need to check project membership for MANAGERs
  if (req.user.role !== 'ADMIN') {
    const isMember = await isProjectMember(req.user.id, task.projectId);
    if (!isMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  // projectId is IGNORED (cannot move task to another project)
  if (title !== undefined) task.title = title;
  if (description !== undefined) task.description = description;
  if (dueDate !== undefined) task.dueDate = dueDate; // null clears it
  if (priority !== undefined) task.priority = priority;

  // If assigneeId is provided (including null), apply the same assignee validation
  if (assigneeId !== undefined) {
    if (assigneeId !== null) {
      // Same assignee rule as creation: must exist, be ACTIVE, be member of project
      const assignee = await User.findByPk(assigneeId);
      if (!assignee) {
        return res.status(400).json({ message: 'User not found' });
      }
      if (assignee.status !== 'ACTIVE') {
        return res.status(400).json({ message: 'Assignee must be an active member of the project' });
      }
      const isAssigneeMember = await ProjectMember.findOne({
        where: { projectId: task.projectId, userId: assigneeId },
      });
      if (!isAssigneeMember) {
        return res.status(400).json({ message: 'Assignee must be an active member of the project' });
      }
    }
    task.assigneeId = assigneeId; // null unassigns
  }

  await task.save();

  // Fetch related data for response
  const [project, assignee, createdBy] = await Promise.all([
    Project.findByPk(task.projectId, { attributes: ['id', 'name'] }),
    task.assigneeId ? User.findByPk(task.assigneeId, { attributes: ['id', 'name'] }) : null,
    User.findByPk(task.createdById, { attributes: ['id', 'name'] }),
  ]);

  return res.status(200).json({
    task: {
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      project: project ? { id: project.id, name: project.name } : null,
      assignee: assignee ? { id: assignee.id, name: assignee.name } : null,
      createdBy: createdBy ? { id: createdBy.id, name: createdBy.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    },
  });
};

// PATCH /tasks/:id/status — update task status
// Allowed for: the assignee, a MANAGER who is a member of the project, or ADMIN
exports.updateTaskStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  const task = await Task.findByPk(id);
  if (!task) {
    return res.status(404).json({ message: 'Task not found' });
  }

  // Allowed for: assignee, MANAGER member, ADMIN
  if (req.user.role !== 'ADMIN') {
    const isManagerMember = req.user.role === 'MANAGER' && (await isProjectMember(req.user.id, task.projectId));
    const isAssignee = task.assigneeId === req.user.id;
    if (!isAssignee && !isManagerMember) {
      return res.status(403).json({ message: 'Forbidden' });
    }
  }

  task.status = status;
  await task.save();

  // Fetch related data for response
  const [project, assignee, createdBy] = await Promise.all([
    Project.findByPk(task.projectId, { attributes: ['id', 'name'] }),
    task.assigneeId ? User.findByPk(task.assigneeId, { attributes: ['id', 'name'] }) : null,
    User.findByPk(task.createdById, { attributes: ['id', 'name'] }),
  ]);

  return res.status(200).json({
    task: {
      id: task.id,
      title: task.title,
      description: task.description,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      createdById: task.createdById,
      priority: task.priority,
      dueDate: task.dueDate,
      status: task.status,
      project: project ? { id: project.id, name: project.name } : null,
      assignee: assignee ? { id: assignee.id, name: assignee.name } : null,
      createdBy: createdBy ? { id: createdBy.id, name: createdBy.name } : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    },
  });
};
