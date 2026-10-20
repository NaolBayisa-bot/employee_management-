const { ActivityLog } = require('../models');

// Allowed actions
const ACTIONS = {
  USER_APPROVED: 'USER_APPROVED',
  USER_ROLE_CHANGED: 'USER_ROLE_CHANGED',
  USER_DEACTIVATED: 'USER_DEACTIVATED',
  USER_REACTIVATED: 'USER_REACTIVATED',
  PROJECT_CREATED: 'PROJECT_CREATED',
  PROJECT_UPDATED: 'PROJECT_UPDATED',
  MEMBER_ADDED: 'MEMBER_ADDED',
  TASK_CREATED: 'TASK_CREATED',
  TASK_UPDATED: 'TASK_UPDATED',
  TASK_ASSIGNED: 'TASK_ASSIGNED',
  TASK_STATUS_CHANGED: 'TASK_STATUS_CHANGED',
};

/**
 * log({ actorId, action, entityType, entityId, projectId = null, meta = {} })
 * Never throws — wraps everything in try/catch.
 * Called with await from controllers AFTER the main action succeeded.
 */
async function log({ actorId, action, entityType, entityId, projectId = null, meta = {} }) {
  try {
    await ActivityLog.create({
      actorId,
      action,
      entityType,
      entityId,
      projectId,
      meta,
    });
  } catch (err) {
    console.error('ActivityLog failed:', err.message);
  }
}

module.exports = { ACTIONS, log };
