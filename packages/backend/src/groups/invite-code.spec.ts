import { generateInviteCode, INVITE_CODE_ALPHABET } from './invite-code';

describe('generateInviteCode', () => {
  it('should make 6-character codes from the alphabet only', () => {
    for (let i = 0; i < 1000; i++) {
      const code = generateInviteCode();
      expect(code).toHaveLength(6);
      for (const char of code) expect(INVITE_CODE_ALPHABET).toContain(char);
    }
  });

  it('should leave out lookalike characters', () => {
    for (const char of ['I', 'L', 'O', '0', '1']) expect(INVITE_CODE_ALPHABET).not.toContain(char);
  });

  it('should use the injected random source', () => {
    expect(generateInviteCode(() => 0)).toBe('AAAAAA');
    expect(generateInviteCode((max) => max - 1)).toBe('999999');
  });
});
