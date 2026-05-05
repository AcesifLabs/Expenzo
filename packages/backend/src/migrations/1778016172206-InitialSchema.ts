import { MigrationInterface, QueryRunner } from "typeorm";

export class InitialSchema1778016172206 implements MigrationInterface {
    name = 'InitialSchema1778016172206'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "users" ("id" text NOT NULL, "firebaseUid" character varying NOT NULL, "email" character varying NOT NULL, "displayName" character varying, "photoUrl" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_e621f267079194e5428e19af2f3" UNIQUE ("firebaseUid"), CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "records" ("id" text NOT NULL, "userId" text NOT NULL, "amount" numeric(12,2) NOT NULL, "description" character varying NOT NULL, "date" TIMESTAMP WITH TIME ZONE NOT NULL, "categoryId" text, "source" character varying NOT NULL DEFAULT 'manual', "sourceId" character varying, "recordType" character varying NOT NULL, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_188149422ee2454660abf1d5ee5" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_095c7c08f73c2d150c0fa1474f" ON "records" ("userId", "categoryId") `);
        await queryRunner.query(`CREATE INDEX "IDX_9b7abd7e52f4dd2d32060c9630" ON "records" ("userId", "date") `);
        await queryRunner.query(`CREATE TABLE "categories" ("id" text NOT NULL, "userId" text NOT NULL, "name" character varying NOT NULL, "emoji" character varying NOT NULL DEFAULT 'package', "color" character varying NOT NULL DEFAULT '#2196F3', "isDefault" boolean NOT NULL DEFAULT false, "categoryType" character varying NOT NULL DEFAULT 'OUT', "usageCount" integer NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_24dbc6126a28ff948da33e97d3b" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_13e8b2a21988bec6fdcbb1fa74" ON "categories" ("userId") `);
        await queryRunner.query(`CREATE TABLE "budgets" ("id" text NOT NULL, "userId" text NOT NULL, "categoryId" text, "amount" numeric(12,2) NOT NULL, "period" character varying NOT NULL, "startDate" TIMESTAMP WITH TIME ZONE NOT NULL, "rolloverEnabled" boolean NOT NULL DEFAULT false, "rolloverAmount" numeric(12,2) NOT NULL DEFAULT '0', "isEnabled" boolean NOT NULL DEFAULT true, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_9c8a51748f82387644b773da482" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_ca58c03face4f6c58cfd45fc3d" ON "budgets" ("userId", "startDate") `);
        await queryRunner.query(`CREATE TABLE "message_sources" ("id" text NOT NULL, "userId" text NOT NULL, "contactId" character varying NOT NULL, "contactName" character varying NOT NULL, "isMonitored" boolean NOT NULL DEFAULT false, "autoCreateOption" integer NOT NULL DEFAULT '1', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_4c5b4fadfe613a7346094f5b289" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "expense_templates" ("id" text NOT NULL, "userId" text NOT NULL, "sourceId" text NOT NULL, "sampleMessage" character varying NOT NULL, "triggerWord" character varying NOT NULL, "amountPattern" character varying NOT NULL, "descriptionPattern" character varying, "datePattern" character varying, "categoryId" character varying, "selectedAmount" character varying, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_6182f5140a115ce5e2101902944" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "parsing_rules" ("id" text NOT NULL, "userId" text NOT NULL, "name" character varying NOT NULL, "triggerWords" character varying NOT NULL, "amountPattern" character varying NOT NULL, "datePattern" character varying, "categoryId" character varying, "sourceType" character varying NOT NULL, "isEnabled" boolean NOT NULL DEFAULT true, "priority" integer NOT NULL DEFAULT '0', "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_575f036c2b558b0f0e66a7f9d01" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "recurring_transactions" ("id" text NOT NULL, "userId" text NOT NULL, "description" character varying NOT NULL, "amount" numeric(12,2) NOT NULL, "categoryId" text, "frequency" character varying NOT NULL, "startDate" TIMESTAMP WITH TIME ZONE NOT NULL, "endDate" TIMESTAMP WITH TIME ZONE, "nextOccurrence" TIMESTAMP WITH TIME ZONE NOT NULL, "isActive" boolean NOT NULL DEFAULT true, "autoCreateExpense" boolean NOT NULL DEFAULT true, "dayOfMonth" integer, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_6485db3243762a54992dc0ce3b7" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE TABLE "pending_recurring" ("id" text NOT NULL, "userId" text NOT NULL, "recurringId" text NOT NULL, "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL, "amount" numeric(12,2) NOT NULL, "description" character varying NOT NULL, "categoryId" text, "createdAt" TIMESTAMP NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_72c1c367872bc0ef6bfd3f65efe" PRIMARY KEY ("id"))`);
        await queryRunner.query(`ALTER TABLE "records" ADD CONSTRAINT "FK_b392510e8a9898d395a871bd9cf" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "categories" ADD CONSTRAINT "FK_13e8b2a21988bec6fdcbb1fa741" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "budgets" ADD CONSTRAINT "FK_27e688ddf1ff3893b43065899f9" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "message_sources" ADD CONSTRAINT "FK_f416b857ef103e8c4f76617302f" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "expense_templates" ADD CONSTRAINT "FK_098ce5f969f2071e9f277b1d3cc" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "expense_templates" ADD CONSTRAINT "FK_af609c56c63713a04a751b34d88" FOREIGN KEY ("sourceId") REFERENCES "message_sources"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "parsing_rules" ADD CONSTRAINT "FK_4cf3c1bf1668fcba4122b3d18a8" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "recurring_transactions" ADD CONSTRAINT "FK_ab59c63725771bd11c6e1d719a2" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "pending_recurring" ADD CONSTRAINT "FK_98552b35c2a78bc69c7bf6a0e91" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "pending_recurring" ADD CONSTRAINT "FK_f3eba1f3ff4716aeabdd6af9b0d" FOREIGN KEY ("recurringId") REFERENCES "recurring_transactions"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "pending_recurring" DROP CONSTRAINT "FK_f3eba1f3ff4716aeabdd6af9b0d"`);
        await queryRunner.query(`ALTER TABLE "pending_recurring" DROP CONSTRAINT "FK_98552b35c2a78bc69c7bf6a0e91"`);
        await queryRunner.query(`ALTER TABLE "recurring_transactions" DROP CONSTRAINT "FK_ab59c63725771bd11c6e1d719a2"`);
        await queryRunner.query(`ALTER TABLE "parsing_rules" DROP CONSTRAINT "FK_4cf3c1bf1668fcba4122b3d18a8"`);
        await queryRunner.query(`ALTER TABLE "expense_templates" DROP CONSTRAINT "FK_af609c56c63713a04a751b34d88"`);
        await queryRunner.query(`ALTER TABLE "expense_templates" DROP CONSTRAINT "FK_098ce5f969f2071e9f277b1d3cc"`);
        await queryRunner.query(`ALTER TABLE "message_sources" DROP CONSTRAINT "FK_f416b857ef103e8c4f76617302f"`);
        await queryRunner.query(`ALTER TABLE "budgets" DROP CONSTRAINT "FK_27e688ddf1ff3893b43065899f9"`);
        await queryRunner.query(`ALTER TABLE "categories" DROP CONSTRAINT "FK_13e8b2a21988bec6fdcbb1fa741"`);
        await queryRunner.query(`ALTER TABLE "records" DROP CONSTRAINT "FK_b392510e8a9898d395a871bd9cf"`);
        await queryRunner.query(`DROP TABLE "pending_recurring"`);
        await queryRunner.query(`DROP TABLE "recurring_transactions"`);
        await queryRunner.query(`DROP TABLE "parsing_rules"`);
        await queryRunner.query(`DROP TABLE "expense_templates"`);
        await queryRunner.query(`DROP TABLE "message_sources"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_ca58c03face4f6c58cfd45fc3d"`);
        await queryRunner.query(`DROP TABLE "budgets"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_13e8b2a21988bec6fdcbb1fa74"`);
        await queryRunner.query(`DROP TABLE "categories"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_9b7abd7e52f4dd2d32060c9630"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_095c7c08f73c2d150c0fa1474f"`);
        await queryRunner.query(`DROP TABLE "records"`);
        await queryRunner.query(`DROP TABLE "users"`);
    }

}
