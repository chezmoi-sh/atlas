// *** WARNING: this file was generated by crd2pulumi. ***
// *** Do not edit by hand unless you're certain you know what you are doing! ***

import * as pulumi from "@pulumi/pulumi";
import * as inputs from "../../types/input";
import * as outputs from "../../types/output";
import * as utilities from "../../utilities";

import {ObjectMeta} from "../../meta/v1";

/**
 * ReferenceGrant identifies kinds of resources in other namespaces that are
 * trusted to reference the specified kinds of resources in the same namespace
 * as the policy.
 *
 * Each ReferenceGrant can be used to represent a unique trust relationship.
 * Additional Reference Grants can be used to add to the set of trusted
 * sources of inbound references for the namespace they are defined within.
 *
 * A ReferenceGrant is required for all cross-namespace references in Gateway API
 * (with the exception of cross-namespace Route-Gateway attachment, which is
 * governed by the AllowedRoutes configuration on the Gateway, and cross-namespace
 * Service ParentRefs on a "consumer" mesh Route, which defines routing rules
 * applicable only to workloads in the Route namespace). ReferenceGrants allowing
 * a reference from a Route to a Service are only applicable to BackendRefs.
 *
 * ReferenceGrant is a form of runtime verification allowing users to assert
 * which cross-namespace object references are permitted. Implementations that
 * support ReferenceGrant MUST NOT permit cross-namespace references which have
 * no grant, and MUST respond to the removal of a grant by revoking the access
 * that the grant allowed.
 */
export class ReferenceGrant extends pulumi.CustomResource {
    /**
     * Get an existing ReferenceGrant resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    public static get(name: string, id: pulumi.Input<pulumi.ID>, opts?: pulumi.CustomResourceOptions): ReferenceGrant {
        return new ReferenceGrant(name, undefined as any, { ...opts, id: id });
    }

    /** @internal */
    public static readonly __pulumiType = 'kubernetes:gateway.networking.k8s.io/v1alpha2:ReferenceGrant';

    /**
     * Returns true if the given object is an instance of ReferenceGrant.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    public static isInstance(obj: any): obj is ReferenceGrant {
        if (obj === undefined || obj === null) {
            return false;
        }
        return obj['__pulumiType'] === ReferenceGrant.__pulumiType;
    }

    public readonly apiVersion!: pulumi.Output<"gateway.networking.k8s.io/v1alpha2" | undefined>;
    public readonly kind!: pulumi.Output<"ReferenceGrant" | undefined>;
    public readonly metadata!: pulumi.Output<ObjectMeta | undefined>;
    /**
     * Spec defines the desired state of ReferenceGrant.
     */
    public readonly spec!: pulumi.Output<outputs.gateway.v1alpha2.ReferenceGrantSpec | undefined>;

    /**
     * Create a ReferenceGrant resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args?: ReferenceGrantArgs, opts?: pulumi.CustomResourceOptions) {
        let resourceInputs: pulumi.Inputs = {};
        opts = opts || {};
        if (!opts.id) {
            resourceInputs["apiVersion"] = "gateway.networking.k8s.io/v1alpha2";
            resourceInputs["kind"] = "ReferenceGrant";
            resourceInputs["metadata"] = args ? args.metadata : undefined;
            resourceInputs["spec"] = args ? args.spec : undefined;
        } else {
            resourceInputs["apiVersion"] = undefined /*out*/;
            resourceInputs["kind"] = undefined /*out*/;
            resourceInputs["metadata"] = undefined /*out*/;
            resourceInputs["spec"] = undefined /*out*/;
        }
        opts = pulumi.mergeOptions(utilities.resourceOptsDefaults(), opts);
        super(ReferenceGrant.__pulumiType, name, resourceInputs, opts);
    }
}

/**
 * The set of arguments for constructing a ReferenceGrant resource.
 */
export interface ReferenceGrantArgs {
    apiVersion?: pulumi.Input<"gateway.networking.k8s.io/v1alpha2">;
    kind?: pulumi.Input<"ReferenceGrant">;
    metadata?: pulumi.Input<ObjectMeta>;
    /**
     * Spec defines the desired state of ReferenceGrant.
     */
    spec?: pulumi.Input<inputs.gateway.v1alpha2.ReferenceGrantSpecArgs>;
}
