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
import { Input, Output } from "@pulumi/pulumi";

/**
 * Enforce the Output type on all fields of a type, recursively.
 */
export type OutputOnPrimitive<T> = T extends string | number | boolean
    ? Output<T>
    : T extends (infer U)[]
      ? OutputOnPrimitive<U>[]
      : T extends object
        ? { [K in keyof T]: OutputOnPrimitive<T[K]> }
        : T;

/**
 * Enforce the Input type on all fields of a type, recursively.
 */
export type InputOnPrimitive<T> = T extends string | number | boolean
    ? Input<T>
    : T extends (infer U)[]
      ? InputOnPrimitive<U>[]
      : T extends object
        ? { [K in keyof T]: InputOnPrimitive<T[K]> }
        : T;
