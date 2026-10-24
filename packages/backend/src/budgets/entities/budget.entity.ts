import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { Group } from '../../groups/entities/group.entity';
import { BudgetPeriod } from '../../common/enums/budget-period.enum';
import { DEFAULT_BUDGET_NAME } from '../budgets.constants';

@Entity('budgets')
@Index(['userId', 'startDate'])
@Index(['userId', 'updatedAt'])
@Index(['groupId'])
export class Budget {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('text', { nullable: true })
  categoryId: string;

  @Column({ default: DEFAULT_BUDGET_NAME })
  name: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column({ type: 'varchar' })
  period: BudgetPeriod;

  @Column('timestamptz')
  startDate: Date;

  @Column({ default: false })
  rolloverEnabled: boolean;

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  rolloverAmount: number;

  @Column({ default: true })
  isEnabled: boolean;

  /** Set when the budget is a Shared Budget of this Family Group (ADR 0008). */
  @Column('uuid', { nullable: true })
  groupId: string | null;

  @ManyToOne(() => Group, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'groupId' })
  group?: Group;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
