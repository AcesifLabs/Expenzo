import { Entity, PrimaryColumn, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('records')
@Index(['userId', 'date'])
@Index(['userId', 'categoryId'])
export class Record {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { nullable: false, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column()
  description: string;

  @Column('timestamptz')
  date: Date;

  @Column('text', { nullable: true })
  categoryId: string;

  @Column({ default: 'manual' })
  source: string;

  @Column({ nullable: true })
  sourceId: string;

  @Column()
  recordType: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
