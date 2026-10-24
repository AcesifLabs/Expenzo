/** A member's permission level in a Family Group (CONTEXT.md Group Role). */
export enum GroupRole {
  ADMIN = 'admin',
  MEMBER = 'member',
  VIEWER = 'viewer',
}

/** Characters in an Invite Code. */
export const INVITE_CODE_LENGTH = 6;

/** How long an Invite Code works after it is made. */
export const INVITE_TTL_HOURS = 48;

/** Longest group name accepted. Mobile limits its form field to the same. */
export const GROUP_NAME_MAX_LENGTH = 60;

/** Most members a Family Group may have, the Admin included. */
export const GROUP_MAX_MEMBERS = 10;
