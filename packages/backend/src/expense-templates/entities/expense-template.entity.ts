import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { MessageSource } from '../../message-sources/entities/message-source.entity';

@Entity('expense_templates')
export class ExpenseTemplate {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('text')
  sourceId: string;

  @ManyToOne(() => MessageSource, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sourceId' })
  messageSource: MessageSource;

  @Column()
  sampleMessage: string;

  @Column()
  triggerWord: string;

  @Column()
  amountPattern: string;

  @Column({ nullable: true })
  descriptionPattern: string;

  @Column({ nullable: true })
  datePattern: string;

  @Column({ nullable: true })
  categoryId: string;

  @Column({ nullable: true })
  selectedAmount: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
