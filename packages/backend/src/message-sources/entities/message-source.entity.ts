import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { AutoCreateOption } from '../../common/enums/auto-create-option.enum';

@Entity('message_sources')
@Index(['userId', 'updatedAt'])
export class MessageSource {
  @PrimaryColumn('text')
  id: string;

  @Column('text')
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  contactId: string;

  @Column()
  contactName: string;

  @Column({ default: false })
  isMonitored: boolean;

  @Column({ type: 'int', default: AutoCreateOption.AUTO })
  autoCreateOption: AutoCreateOption;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
