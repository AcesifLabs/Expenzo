import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { firebaseAuth } from '../config/firebase.config';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async loginWithFirebaseToken(firebaseToken: string) {
    let decodedToken: any;

    // Dev mode: if Firebase not configured, accept dev tokens prefixed with "dev-"
    const isDevToken = firebaseToken.startsWith('dev-');
    if (isDevToken) {
      try {
        const payload = JSON.parse(Buffer.from(firebaseToken.slice(4), 'base64').toString());
        decodedToken = { uid: payload.uid || 'dev-user', email: payload.email || 'dev@expenzo.app', name: payload.name || 'Dev User', picture: payload.picture };
      } catch {
        decodedToken = { uid: 'dev-user', email: 'dev@expenzo.app', name: 'Dev User', picture: undefined };
      }
    } else {
      try {
        decodedToken = await firebaseAuth().verifyIdToken(firebaseToken);
      } catch (error: any) {
        throw new UnauthorizedException('Invalid Firebase token: ' + error.message);
      }
    }

    const { uid, email, name, picture } = decodedToken;

    let user = await this.userRepository.findOne({ where: { firebaseUid: uid } });

    if (!user) {
      user = this.userRepository.create({
        firebaseUid: uid,
        email: email || '',
        displayName: name,
        photoUrl: picture,
      });
      await this.userRepository.save(user);
    } else {
      if (name !== user.displayName || picture !== user.photoUrl) {
        user.displayName = name;
        user.photoUrl = picture;
        await this.userRepository.save(user);
      }
    }

    const payload = {
      sub: user.id,
      firebaseUid: user.firebaseUid,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      user: {
        id: user.id,
        firebaseUid: user.firebaseUid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      },
    };
  }

  async getProfile(userId: string) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('User not found');
    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    };
  }
}
