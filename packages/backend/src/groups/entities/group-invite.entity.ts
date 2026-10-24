import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, Index } from 'typeorm';
import { Group } from './group.entity';

@Entity('group_invites')
@Index(['groupId'])
export class GroupInvite {
  @PrimaryColumn({ type: 'char', length: 6 })
  code: string;

  @Column('uuid')
  groupId: string;

  @ManyToOne(() => Group, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'groupId' })
  group?: Group;

  @Column('timestamptz')
  expiresAt: Date;

  @Column('text', { nullable: true })
  createdBy: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
