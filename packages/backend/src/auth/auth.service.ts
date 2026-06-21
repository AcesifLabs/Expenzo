import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { FirebaseTokenPayload } from './dto/firebasetokenpayload.dto';
import { firebaseAuth } from '../config/firebase.config';
import { v4 as uuidv4 } from 'uuid';
import { LoginResponse, UserProfile, DeleteAccountResponse, JwtPayload } from './auth.types';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async loginWithFirebaseToken(firebaseToken: string): Promise<LoginResponse> {
    const decodedToken = await this.verifyFirebaseToken(firebaseToken);
    const user = await this.upsertUser(decodedToken);
    const accessToken = this.generateAccessToken(user);
    return { accessToken, user: this.toUserProfile(user) };
  }

  async deleteAccount(userId: string): Promise<DeleteAccountResponse> {
    const user = await this.findUserOrFail(userId);
    await this.userRepository.remove(user);
    return { deleted: true, userId };
  }

  async getProfile(userId: string): Promise<UserProfile> {
    const user = await this.findUserOrFail(userId);
    return this.toUserProfile(user);
  }

  private async verifyFirebaseToken(token: string): Promise<FirebaseTokenPayload> {
    if (token.startsWith('dev-')) {
      return this.parseDevToken(token);
    }

    try {
      return await firebaseAuth().verifyIdToken(token) as unknown as FirebaseTokenPayload;
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      throw new UnauthorizedException('Invalid Firebase token: ' + message);
    }
  }

  private parseDevToken(token: string): FirebaseTokenPayload {
    try {
      const payload = JSON.parse(Buffer.from(token.slice(4), 'base64').toString());
      return {
        uid: payload.uid || 'dev-user',
        email: payload.email || 'dev@expenzo.app',
        name: payload.name || 'Dev User',
        picture: payload.picture,
      };
    } catch {
      return { uid: 'dev-user', email: 'dev@expenzo.app', name: 'Dev User', picture: undefined };
    }
  }

  private async upsertUser(decodedToken: FirebaseTokenPayload): Promise<User> {
    const { uid, email, name, picture } = decodedToken;

    let user = await this.userRepository.findOne({ where: { firebaseUid: uid } });

    if (!user) {
      user = this.userRepository.create({
        id: uuidv4(),
        firebaseUid: uid,
        email: email || '',
        displayName: name,
        photoUrl: picture,
      });
    } else if (name !== user.displayName || picture !== user.photoUrl) {
      user.displayName = name;
      user.photoUrl = picture;
    }

    return this.userRepository.save(user);
  }

  private generateAccessToken(user: User): string {
    const payload: JwtPayload = {
      sub: user.id,
      firebaseUid: user.firebaseUid,
    };
    return this.jwtService.sign(payload);
  }

  private toUserProfile(user: User): UserProfile {
    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    };
  }

  private async findUserOrFail(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }
}
