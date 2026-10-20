const { ActivityLog, User } = require('../models');
const { Op } = require('sequelize');

/**
 * GET /activity
 * Returns paginated activity logs for the admin.
 * Query params (all optional):
 *   page (int >= 1, default 1), limit (int 1–100, default 20)
 *   userId (UUID) — filter by actorId
 *   action (must be in ALLOWED_ACTIONS)
 *   entityType (USER | PROJECT | TASK)
 *   projectId (UUID)
 *   from / to (ISO dates, inclusive on createdAt)
 */
exports.getActivity = async (req, res) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 20;
  const offset = (page - 1) * limit;

  // Build dynamic where clause
  const where = {};

  if (req.query.userId) {
    where.actorId = req.query.userId;
  }

  if (req.query.action) {
    where.action = req.query.action;
  }

  if (req.query.entityType) {
    where.entityType = req.query.entityType;
  }

  if (req.query.projectId) {
    where.projectId = req.query.projectId;
  }

  // createdAt range filter (inclusive)
  if (req.query.from || req.query.to) {
    where.createdAt = {};
    if (req.query.from) {
      where.createdAt[Op.gte] = req.query.from;
    }
    if (req.query.to) {
      where.createdAt[Op.lte] = req.query.to;
    }
  }

  const { count, rows } = await ActivityLog.findAndCountAll({
    where,
    limit,
    offset,
    order: [['createdAt', 'DESC'], ['id', 'DESC']],
    include: [
      {
        model: User,
        as: 'actor',
        attributes: ['id', 'name'],
      },
    ],
  });

  const items = rows.map((log) => ({
    id: log.id,
    action: log.action,
    entityType: log.entityType,
    entityId: log.entityId,
    projectId: log.projectId,
    meta: log.meta,
    createdAt: log.createdAt,
    actor: log.actor ? { id: log.actor.id, name: log.actor.name } : null,
  }));

  const totalPages = Math.ceil(count / limit);

  return res.status(200).json({
    items,
    page,
    limit,
    total: count,
    totalPages,
  });
};
