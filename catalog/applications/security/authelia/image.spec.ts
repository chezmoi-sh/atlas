import { randomUUID } from "crypto";
import tmp from "tmp";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

import { automation } from "@pulumi/pulumi";

import { AlpineImage, Version as AlpineVersion } from "@catalog.chezmoi.sh/os~alpine-3.19";

import { AutheliaImage, Version } from "./image";

const isIntegration = (process.env.VITEST_RUN_TYPE ?? "").includes("integration:docker");
const timeout = 10 * 60 * 1000; // 10 minutes

const AlpineImageTag = `${process.env.CI_OCI_REGISTRY ?? "oci.local.chezmoi.sh"}/os/alpine:${AlpineVersion}`;
const AutheliaImageTag = `${process.env.CI_OCI_REGISTRY ?? "oci.local.chezmoi.sh"}/security/authelia:${Version}`;

describe.runIf(isIntegration)("(Security) Authelia", () => {
    describe("AutheliaImage", () => {
        // -- Prepare Pulumi execution --
        const program = async () => {
            const alpine = new AlpineImage(randomUUID(), { push: true, tags: [AlpineImageTag] });
            const authelia = new AutheliaImage(randomUUID(), {
                from: alpine,
                push: true,
                tags: [AutheliaImageTag],
            });
            return { ...authelia };
        };

        let stack: automation.Stack;
        let result: automation.UpResult;
        beforeAll(async () => {
            const tmpdir = tmp.dirSync();
            stack = await automation.LocalWorkspace.createOrSelectStack(
                {
                    stackName: "authelia",
                    projectName: "authelia",
                    program,
                },
                {
                    secretsProvider: "passphrase",
                    projectSettings: {
                        name: "authelia",
                        runtime: "nodejs",
                        backend: {
                            url: `file://${tmpdir.name}`,
                        },
                    },
                },
            );
            result = await stack.up();
        }, timeout);

        afterAll(async () => {
            await stack.destroy();
        }, timeout);

        // -- Assertions --
        it("should be successfully built", () => {
            expect(result.summary.result).toBe("succeeded");
            expect(result.outputs?.ref.value).toContain(AutheliaImageTag);
        });
    });
});