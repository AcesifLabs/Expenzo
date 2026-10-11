import { MigrationInterface, QueryRunner } from "typeorm";

export class AddBudgetName1791718353157 implements MigrationInterface {
    name = 'AddBudgetName1791718353157'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "budgets" ADD "name" character varying NOT NULL DEFAULT 'Unnamed budget'`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "budgets" DROP COLUMN "name"`);
    }
}
