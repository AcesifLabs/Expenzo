import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, Index, Check } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { GroupRole } from '../groups.constants';
import { Group } from './group.entity';

@Entity('group_members')

@Index(['userId'], { unique: true })
@Check('CHK_group_members_role', `"role" IN ('admin', 'member', 'viewer')`)
export class GroupMember {
  @PrimaryColumn('uuid')
  groupId: string;

  @ManyToOne(() => Group, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'groupId' })
  group?: Group;

  @PrimaryColumn('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user?: User;

  @Column({ type: 'varchar' })
  role: GroupRole;

  @CreateDateColumn({ type: 'timestamptz' })
  joinedAt: Date;
}
