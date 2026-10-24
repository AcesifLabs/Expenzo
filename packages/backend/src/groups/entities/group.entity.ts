import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('groups')
export class Group {
  // Made by GroupsService with uuidv4(), like user ids, so the schema needs no
  // uuid extension.
  @PrimaryColumn('uuid')
  id: string;

  @Column('text')
  name: string;

  @Column({ type: 'char', length: 3 })
  currencyCode: string;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  monthlyBudget: number | null;

  // Nullable with SET NULL: deleting the creator's account must not delete
  // the group or fail on the foreign key.
  @Column('text', { nullable: true })
  createdBy: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'createdBy' })
  creator?: User;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
