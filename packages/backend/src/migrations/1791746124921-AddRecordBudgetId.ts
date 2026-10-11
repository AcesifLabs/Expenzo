import { MigrationInterface, QueryRunner } from "typeorm";

export class AddRecordBudgetId1791746124921 implements MigrationInterface {
    name = 'AddRecordBudgetId1791746124921'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "records" ADD "budgetId" text`);
        await queryRunner.query(`CREATE INDEX "IDX_d123d7c0d81f9a20cd5704df74" ON "records" ("userId", "budgetId") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_d123d7c0d81f9a20cd5704df74"`);
        await queryRunner.query(`ALTER TABLE "records" DROP COLUMN "budgetId"`);
    }
}
