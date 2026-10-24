import { MigrationInterface, QueryRunner } from "typeorm";

export class AddGroups1792854426416 implements MigrationInterface {
    name = 'AddGroups1792854426416'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "groups" ("id" uuid NOT NULL, "name" text NOT NULL, "currencyCode" character(3) NOT NULL, "monthlyBudget" numeric(12,2), "createdBy" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_659d1483316afb28afd3a90646e" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "group_members" ("groupId" uuid NOT NULL, "userId" text NOT NULL, "role" character varying NOT NULL, "joinedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "CHK_group_members_role" CHECK ("role" IN ('admin', 'member', 'viewer')), CONSTRAINT "PK_53f644f66a416c1542b743c0295" PRIMARY KEY ("groupId", "userId"))`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_fdef099303bcf0ffd9a4a7b18f" ON "group_members" ("userId") `);
        await queryRunner.query(`CREATE TABLE "group_invites" ("code" character(6) NOT NULL, "groupId" uuid NOT NULL, "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL, "createdBy" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_145bbc40f47d34c458ed6e9d96f" PRIMARY KEY ("code"))`);
        await queryRunner.query(`CREATE INDEX "IDX_a19036d19bd85c157b035d78c8" ON "group_invites" ("groupId") `);
        await queryRunner.query(`ALTER TABLE "groups" ADD CONSTRAINT "FK_1dbe6126bee8f0b4678e50e60cc" FOREIGN KEY ("createdBy") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "group_members" ADD CONSTRAINT "FK_1aa8d31831c3126947e7a713c2b" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "group_members" ADD CONSTRAINT "FK_fdef099303bcf0ffd9a4a7b18f5" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "group_invites" ADD CONSTRAINT "FK_a19036d19bd85c157b035d78c8a" FOREIGN KEY ("groupId") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "group_invites" DROP CONSTRAINT "FK_a19036d19bd85c157b035d78c8a"`);
        await queryRunner.query(`ALTER TABLE "group_members" DROP CONSTRAINT "FK_fdef099303bcf0ffd9a4a7b18f5"`);
        await queryRunner.query(`ALTER TABLE "group_members" DROP CONSTRAINT "FK_1aa8d31831c3126947e7a713c2b"`);
        await queryRunner.query(`ALTER TABLE "groups" DROP CONSTRAINT "FK_1dbe6126bee8f0b4678e50e60cc"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_a19036d19bd85c157b035d78c8"`);
        await queryRunner.query(`DROP TABLE "group_invites"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_fdef099303bcf0ffd9a4a7b18f"`);
        await queryRunner.query(`DROP TABLE "group_members"`);
        await queryRunner.query(`DROP TABLE "groups"`);
    }

}
