import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { TransactionFrequency } from '../../common/enums/transaction-frequency.enum';

@Entity('recurring_transactions')
@Index(['userId', 'updatedAt'])
export class RecurringTransaction {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  description: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column('text', { nullable: true })
  categoryId: string;

  @Column({ type: 'varchar', default: TransactionFrequency.MONTHLY })
  frequency: TransactionFrequency;

  @Column('timestamptz')
  startDate: Date;

  @Column('timestamptz', { nullable: true })
  endDate: Date;

  @Column('timestamptz')
  nextOccurrence: Date;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: true })
  autoCreateExpense: boolean;

  @Column({ nullable: true })
  dayOfMonth: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
