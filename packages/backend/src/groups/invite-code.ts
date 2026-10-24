import { randomInt } from 'crypto';
import { INVITE_CODE_LENGTH } from './groups.constants';

/** A–Z and 2–9 without the lookalikes I, L and O (0 and 1 are not in 2–9). */
export const INVITE_CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/** A random Invite Code. [random] is only replaced in tests. */
export function generateInviteCode(random: (max: number) => number = randomInt): string {
  let code = '';
  for (let i = 0; i < INVITE_CODE_LENGTH; i++) code += INVITE_CODE_ALPHABET[random(INVITE_CODE_ALPHABET.length)];
  return code;
}
