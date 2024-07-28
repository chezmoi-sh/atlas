/*
 * Copyright (C) 2024 Alexandre Nicolaie (xunleii@users.noreply.github.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ----------------------------------------------------------------------------
 */
import { randomUUID } from "crypto";
import tmp from "tmp";
import { TestOptions, afterAll, beforeAll, describe, expect, it } from "vitest";

import { Output, automation } from "@pulumi/pulumi";

/**
 * The `PulumiScenarioOptions` interface contains all options required to create a new
 * Pulumi scenario on Pulumi.
 */
export interface PulumiScenarioOptions extends TestOptions {
    /**
     * The expected result of the stack update operation.
     * @default "succeeded"
     */
    expectedResult?: automation.UpdateResult;
    /**
     * A callback to be executed when the operation produces output.
     */
    onOutput?: (out: string) => void;
    /**
     * Print detailed debugging output during resource operations.
     * */
    debug?: boolean;
}

/**
 * Pulumi scenario is an extension of the `describe` vitest function that
 * provides a Pulumi stack for the test scenario.
 * It defines and manages the lifecycle of a Pulumi stack within the context of a
 * test case. It sets up the necessary Pulumi environment, runs the provided
 * Pulumi program, executes assertions once the stack operations are complete,
 * and tears down the stack when the test case is done.
 *
 * @param name - The name of the test scenario.
 * @param options - The test options.
 * @param program - The Pulumi program function.
 * @param assertions - The assertions to be executed after the Pulumi stack is created.
 *                     This is a callback function that receives an `assertion context` object
 *                     containing the result of the stack update operation, allowing
 *                     you to perform assertions on the stack's state and outputs.
 *                     Note: The result of the stack update operation is only available
 *                     after the `beforeAll` hook is executed and therefore MUST BE USED ONLY
 *                     WITHIN THE `it` OR `test` HOOKS.
 */
export function pulumiScenario(
    name: string,
    options: PulumiScenarioOptions,
    program: automation.PulumiFn,
    assertions?: (context: { result?: automation.UpResult }) => void,
) {
    describe(name, options, () => {
        const tmpdir = tmp.dirSync({ unsafeCleanup: true });
        const projectName = randomUUID().substring(0, 11);
        const stackName = randomUUID().substring(0, 8);
        const promisedStack = automation.LocalWorkspace.createOrSelectStack(
            {
                stackName: stackName,
                projectName: projectName,
                program,
            },
            {
                secretsProvider: "passphrase",
                projectSettings: {
                    name: projectName,
                    runtime: "nodejs",
                    backend: {
                        url: `file://${tmpdir.name}`,
                    },
                },
            },
        );

        let context: { result?: automation.UpResult } = {};

        beforeAll(async () => {
            const stack = await promisedStack;
            const result = await stack.up({ onOutput: options.onOutput, debug: options.debug });
            if (result.summary.result != "succeeded") {
                console.info(result.stdout);
                console.error(result.stderr);
            }
            context.result = result;
        }, options.timeout);

        afterAll(async () => {
            const stack = await promisedStack;
            if (!context.result) {
                // NOTE: if result is not defined, it means that `up` hasn't
                //       finished yet
                await stack.cancel();
            }
            await stack.destroy({ onOutput: options.onOutput, debug: options.debug });
        }, options.timeout);

        it(`stack deployment should ${options.expectedResult ?? "succeed"}`, () => {
            const result = context.result;
            expect(result?.summary.result).toEqual(options.expectedResult ?? "succeeded");
        });
        assertions?.(context);
    });
}

/**
 * Promisify a Pulumi output.
 * @param output - The Pulumi output to be promisified.
 */
export function promisifyPulumiOutput<T>(output?: Output<T>): Promise<T> {
    return new Promise((resolve) => output?.apply(resolve));
}
