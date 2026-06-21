import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { RecordSource } from '../../common/enums/record-source.enum';
import { CategoryType } from '../../common/enums/category-type.enum';

@Entity('records')
@Index(['userId', 'date'])
@Index(['userId', 'categoryId'])
@Index(['userId', 'updatedAt'])
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

  @Column({ type: 'varchar', default: RecordSource.MANUAL })
  source: RecordSource;

  @Column({ nullable: true })
  sourceId: string;

  @Column({ type: 'varchar' })
  recordType: CategoryType;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
