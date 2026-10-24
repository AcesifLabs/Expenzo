import { MigrationInterface, QueryRunner } from "typeorm";

export class AddBudgetGroupId1792854433516 implements MigrationInterface {
    name = 'AddBudgetGroupId1792854433516'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "budgets" ADD "groupId" uuid`);
        await queryRunner.query(`CREATE INDEX "IDX_ed712895493adc57d592a1b468" ON "budgets" ("groupId") `);
        await queryRunner.query(`ALTER TABLE "budgets" ADD CONSTRAINT "FK_ed712895493adc57d592a1b468c" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "budgets" DROP CONSTRAINT "FK_ed712895493adc57d592a1b468c"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_ed712895493adc57d592a1b468"`);
        await queryRunner.query(`ALTER TABLE "budgets" DROP COLUMN "groupId"`);
    }

}
