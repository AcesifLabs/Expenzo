import { ConflictException, GoneException, HttpException, NotFoundException } from '@nestjs/common';
import { GroupErrorBody, GroupErrorCode } from './groups.types';

const body = (code: GroupErrorCode, message: string): GroupErrorBody => ({ code, message });


export const groupErrors = {
  alreadyInGroup: (): HttpException => new ConflictException(body('ALREADY_IN_GROUP', 'Already in a family group')),
  notInGroup: (): HttpException => new NotFoundException(body('NOT_IN_GROUP', 'Not a member of this group')),
  inviteNotFound: (): HttpException => new NotFoundException(body('INVITE_NOT_FOUND', 'No group uses this code')),
  inviteExpired: (): HttpException => new GoneException(body('INVITE_EXPIRED', 'This code has expired')),
  currencyMismatch: (groupCurrency: string): HttpException =>
    new ConflictException({ ...body('CURRENCY_MISMATCH', 'The group uses another currency'), groupCurrency }),
  groupFull: (): HttpException => new ConflictException(body('GROUP_FULL', 'Group is full')),
  lastAdmin: (): HttpException => new ConflictException(body('LAST_ADMIN', 'The group needs another admin first')),
};
