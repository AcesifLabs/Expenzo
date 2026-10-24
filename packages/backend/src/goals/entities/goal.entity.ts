import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index, Check } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

/** A savings target. Progress (`savedAmount`) is entered by hand (ADR 0009). */
@Entity('goals')
@Index(['userId', 'updatedAt'])
@Check('CHK_goals_target_positive', '"targetAmount" > 0')
@Check('CHK_goals_saved_non_negative', '"savedAmount" >= 0')
export class Goal {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('text')
  name: string;

  @Column('decimal', { precision: 12, scale: 2 })
  targetAmount: number;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  savedAmount: number;

  @Column('timestamptz', { nullable: true })
  targetDate: Date | null;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  monthlyContribution: number | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
