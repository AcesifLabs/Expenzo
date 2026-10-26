import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('groups')
export class Group {
  
  
  @PrimaryColumn('uuid')
  id: string;

  @Column('text')
  name: string;

  @Column({ type: 'char', length: 3 })
  currencyCode: string;

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  monthlyBudget: number | null;

  
  
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
