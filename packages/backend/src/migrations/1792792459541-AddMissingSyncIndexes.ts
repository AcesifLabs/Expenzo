import { MigrationInterface, QueryRunner } from "typeorm";



export class AddMissingSyncIndexes1792792459541 implements MigrationInterface {
    name = 'AddMissingSyncIndexes1792792459541'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "recurring_transactions" ALTER COLUMN "frequency" SET DEFAULT 'monthly'`);
        await queryRunner.query(`CREATE INDEX "IDX_e89a248a081974bec0c1de5ea5" ON "records" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_370a367f65d7e356ce4d37c645" ON "categories" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_f49817040771f45ac769e038cb" ON "budgets" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_af765220bcf9630185c101bde3" ON "message_sources" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_46122136dfbcdcf2f80589a228" ON "expense_templates" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_2bf36b6c5806d2890aae99bed8" ON "parsing_rules" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_931247e350a75559fddbd32632" ON "recurring_transactions" ("userId", "updatedAt") `);
        await queryRunner.query(`CREATE INDEX "IDX_805d0c055294917ed619226f24" ON "pending_recurring" ("userId", "updatedAt") `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP INDEX "public"."IDX_805d0c055294917ed619226f24"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_931247e350a75559fddbd32632"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_2bf36b6c5806d2890aae99bed8"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_46122136dfbcdcf2f80589a228"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_af765220bcf9630185c101bde3"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_f49817040771f45ac769e038cb"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_370a367f65d7e356ce4d37c645"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_e89a248a081974bec0c1de5ea5"`);
        await queryRunner.query(`ALTER TABLE "recurring_transactions" ALTER COLUMN "frequency" DROP DEFAULT`);
    }
}
