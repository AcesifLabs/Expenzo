import { MigrationInterface, QueryRunner } from "typeorm";

export class AddGoals1792792459542 implements MigrationInterface {
    name = 'AddGoals1792792459542'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "goals" ("id" text NOT NULL, "userId" text NOT NULL, "name" text NOT NULL, "targetAmount" numeric(12,2) NOT NULL, "savedAmount" numeric(12,2) NOT NULL DEFAULT '0', "targetDate" TIMESTAMP WITH TIME ZONE, "monthlyContribution" numeric(12,2), "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "CHK_goals_saved_non_negative" CHECK ("savedAmount" >= 0), CONSTRAINT "CHK_goals_target_positive" CHECK ("targetAmount" > 0), CONSTRAINT "PK_26e17b251afab35580dff769223" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_750e638d47d4a55cbe253f0dea" ON "goals" ("userId", "updatedAt") `);
        await queryRunner.query(`ALTER TABLE "goals" ADD CONSTRAINT "FK_57dd8a3fc26eb760d076bf8840e" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "goals" DROP CONSTRAINT "FK_57dd8a3fc26eb760d076bf8840e"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_750e638d47d4a55cbe253f0dea"`);
        await queryRunner.query(`DROP TABLE "goals"`);
    }
}
