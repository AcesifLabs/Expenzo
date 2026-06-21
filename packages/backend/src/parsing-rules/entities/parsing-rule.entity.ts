import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('parsing_rules')
@Index(['userId', 'updatedAt'])
export class ParsingRule {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  name: string;

  @Column()
  triggerWords: string;

  @Column()
  amountPattern: string;

  @Column({ nullable: true })
  datePattern: string;

  @Column({ nullable: true })
  categoryId: string;

  @Column()
  sourceType: string;

  @Column({ default: true })
  isEnabled: boolean;

  @Column({ default: 0 })
  priority: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
