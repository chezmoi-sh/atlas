// *** WARNING: this file was generated by crd2pulumi. ***
// *** Do not edit by hand unless you're certain you know what you are doing! ***

import * as pulumi from "@pulumi/pulumi";
import * as utilities from "../../utilities";

// Export members:
export { BackendLBPolicyArgs } from "./backendLBPolicy";
export type BackendLBPolicy = import("./backendLBPolicy").BackendLBPolicy;
export const BackendLBPolicy: typeof import("./backendLBPolicy").BackendLBPolicy = null as any;
utilities.lazyLoad(exports, ["BackendLBPolicy"], () => require("./backendLBPolicy"));

export { GRPCRouteArgs } from "./grpcroute";
export type GRPCRoute = import("./grpcroute").GRPCRoute;
export const GRPCRoute: typeof import("./grpcroute").GRPCRoute = null as any;
utilities.lazyLoad(exports, ["GRPCRoute"], () => require("./grpcroute"));

export { ReferenceGrantArgs } from "./referenceGrant";
export type ReferenceGrant = import("./referenceGrant").ReferenceGrant;
export const ReferenceGrant: typeof import("./referenceGrant").ReferenceGrant = null as any;
utilities.lazyLoad(exports, ["ReferenceGrant"], () => require("./referenceGrant"));

export { TCPRouteArgs } from "./tcproute";
export type TCPRoute = import("./tcproute").TCPRoute;
export const TCPRoute: typeof import("./tcproute").TCPRoute = null as any;
utilities.lazyLoad(exports, ["TCPRoute"], () => require("./tcproute"));

export { TLSRouteArgs } from "./tlsroute";
export type TLSRoute = import("./tlsroute").TLSRoute;
export const TLSRoute: typeof import("./tlsroute").TLSRoute = null as any;
utilities.lazyLoad(exports, ["TLSRoute"], () => require("./tlsroute"));

export { UDPRouteArgs } from "./udproute";
export type UDPRoute = import("./udproute").UDPRoute;
export const UDPRoute: typeof import("./udproute").UDPRoute = null as any;
utilities.lazyLoad(exports, ["UDPRoute"], () => require("./udproute"));


const _module = {
    version: utilities.getVersion(),
    construct: (name: string, type: string, urn: string): pulumi.Resource => {
        switch (type) {
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:BackendLBPolicy":
                return new BackendLBPolicy(name, <any>undefined, { urn })
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:GRPCRoute":
                return new GRPCRoute(name, <any>undefined, { urn })
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:ReferenceGrant":
                return new ReferenceGrant(name, <any>undefined, { urn })
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:TCPRoute":
                return new TCPRoute(name, <any>undefined, { urn })
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:TLSRoute":
                return new TLSRoute(name, <any>undefined, { urn })
            case "kubernetes:gateway.networking.k8s.io/v1alpha2:UDPRoute":
                return new UDPRoute(name, <any>undefined, { urn })
            default:
                throw new Error(`unknown resource type ${type}`);
        }
    },
};
pulumi.runtime.registerResourceModule("kubernetes-gateway.networking.k8s.io", "gateway.networking.k8s.io/v1alpha2", _module)
