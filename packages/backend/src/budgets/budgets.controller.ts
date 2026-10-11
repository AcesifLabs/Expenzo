import { Body, Controller, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { BudgetsService } from './budgets.service';
import { FillBudgetNamesDto } from './dto/fill-budget-names.dto';

@Controller('budgets')
@UseGuards(JwtAuthGuard)
export class BudgetsController {
  constructor(private readonly budgetsService: BudgetsService) {}

  @Post('names')
  @HttpCode(HttpStatus.OK)
  fillMissingNames(@CurrentUser('sub') userId: string, @Body() dto: FillBudgetNamesDto) {
    return this.budgetsService.fillMissingNames(userId, dto.names);
  }
}
