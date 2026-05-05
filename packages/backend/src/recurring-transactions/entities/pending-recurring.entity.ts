import { Entity, PrimaryColumn, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { RecurringTransaction } from './recurring-transaction.entity';

@Entity('pending_recurring')
export class PendingRecurring {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('text')
  recurringId: string;

  @ManyToOne(() => RecurringTransaction, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'recurringId' })
  recurringTransaction: RecurringTransaction;

  @Column('timestamptz')
  dueDate: Date;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column()
  description: string;

  @Column('text', { nullable: true })
  categoryId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
