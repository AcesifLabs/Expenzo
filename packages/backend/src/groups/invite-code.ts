import { randomInt } from 'crypto';
import { INVITE_CODE_LENGTH } from './groups.constants';


export const INVITE_CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';


export function generateInviteCode(random: (max: number) => number = randomInt): string {
  let code = '';
  for (let i = 0; i < INVITE_CODE_LENGTH; i++) code += INVITE_CODE_ALPHABET[random(INVITE_CODE_ALPHABET.length)];
  return code;
}
