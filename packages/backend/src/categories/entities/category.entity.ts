import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { CategoryType } from '../../common/enums/category-type.enum';

@Entity('categories')
@Index(['userId'])
@Index(['userId', 'updatedAt'])
export class Category {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  name: string;

  @Column({ default: 'package' })
  emoji: string;

  @Column({ default: '#2196F3' })
  color: string;

  @Column({ default: false })
  isDefault: boolean;

  @Column({ type: 'varchar', default: CategoryType.EXPENSE })
  categoryType: CategoryType;

  @Column({ default: 0 })
  usageCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
