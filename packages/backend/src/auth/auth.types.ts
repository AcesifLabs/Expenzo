export interface UserProfile {
  id: string;
  firebaseUid: string;
  email: string;
  displayName: string;
  photoUrl: string;
}

export interface LoginResponse {
  accessToken: string;
  user: UserProfile;
}

export interface JwtPayload {
  sub: string;
  firebaseUid: string;
}

export interface DeleteAccountResponse {
  deleted: boolean;
  userId: string;
}
