export interface JwtPayload {
  sub: string;
  firebaseUid: string;
  iat: number;
  exp: number;
}
