import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { BudgetPeriod } from '../../common/enums/budget-period.enum';

@Entity('budgets')
@Index(['userId', 'startDate'])
@Index(['userId', 'updatedAt'])
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

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
