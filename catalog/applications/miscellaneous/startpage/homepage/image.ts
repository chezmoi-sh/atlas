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
import path from "path";

import * as buildkit from "@pulumi/docker-build";
import * as pulumi from "@pulumi/pulumi";

import { Version } from "./version";

export { Version };

/**
 * The set of arguments for constructing the Homepage Docker image.
 */
export type ImageArgs = Omit<buildkit.ImageArgs, "buildArgs" | "context" | "dockerfile">;

/**
 * A Homepage Docker image baked by buildkit -- Docker's interface to the improved
 * BuildKit backend.
 */
export class HomepageImage extends buildkit.Image {
    constructor(name: string, args: ImageArgs, opts?: pulumi.ComponentResourceOptions) {
        super(
            name,
            {
                ...args,

                // Build the image
                dockerfile: { location: path.join(__dirname, "Dockerfile") },
                buildArgs: {
                    HOMEPAGE_VERSION: Version,
                },
            },
            opts,
        );
    }
}
