import { MigrationInterface, QueryRunner } from "typeorm";

// Matching rules were removed from the app (docs/adr/0017-remove-matching-rules.md).
export class DropParsingRules1792900000000 implements MigrationInterface {
    name = 'DropParsingRules1792900000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`DROP TABLE "parsing_rules"`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "parsing_rules" ("id" text NOT NULL, "userId" text NOT NULL, "name" character varying NOT NULL, "triggerWords" character varying NOT NULL, "amountPattern" character varying NOT NULL, "datePattern" character varying, "categoryId" character varying, "sourceType" character varying NOT NULL, "isEnabled" boolean NOT NULL DEFAULT true, "priority" integer NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_575f036c2b558b0f0e66a7f9d01" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_2bf36b6c5806d2890aae99bed8" ON "parsing_rules" ("userId", "updatedAt") `);
        await queryRunner.query(`ALTER TABLE "parsing_rules" ADD CONSTRAINT "FK_4cf3c1bf1668fcba4122b3d18a8" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }
}
