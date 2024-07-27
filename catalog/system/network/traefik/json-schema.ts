import { asConst } from "json-schema-to-ts";

export const TraefikV2JsonSchema = asConst({
    $schema: "http://json-schema.org/draft-04/schema#",
    additionalProperties: false,
    id: "https://json.schemastore.org/traefik-v2.json",
    properties: {
        accessLog: {
            type: "object",
            properties: {
                addInternals: { type: "boolean", default: false },
                filePath: { type: "string" },
                format: { type: "string" },
                bufferingSize: { type: "integer" },
                filters: {
                    type: "object",
                    properties: {
                        statusCodes: { type: "array", items: { type: "string" } },
                        retryAttempts: { type: "boolean" },
                        minDuration: { type: "string" },
                    },
                },
                fields: {
                    type: "object",
                    properties: {
                        defaultMode: { type: "string" },
                        names: { type: "object", patternProperties: { "[a-zA-Z0-9-_]+": { type: "string" } } },
                        headers: {
                            type: "object",
                            properties: {
                                defaultMode: { type: "string" },
                                names: { type: "object", patternProperties: { "[a-zA-Z0-9-_]+": { type: "string" } } },
                            },
                        },
                    },
                },
            },
            additionalProperties: false,
        },
        api: {
            type: "object",
            properties: { insecure: { type: "boolean" }, dashboard: { type: "boolean" }, debug: { type: "boolean" } },
            additionalProperties: false,
        },
        certificatesResolvers: {
            type: "object",
            patternProperties: {
                "[a-zA-Z0-9-_]+": {
                    type: "object",
                    properties: {
                        acme: {
                            type: "object",
                            properties: {
                                email: { type: "string" },
                                caServer: { type: "string" },
                                certificatesDuration: { type: "integer" },
                                preferredChain: { type: "string" },
                                storage: { type: "string" },
                                keyType: { type: "string" },
                                eab: {
                                    type: "object",
                                    properties: { kid: { type: "string" }, hmacEncoded: { type: "string" } },
                                },
                                dnsChallenge: {
                                    type: "object",
                                    properties: {
                                        provider: { type: "string" },
                                        delayBeforeCheck: { type: "string" },
                                        resolvers: { type: "array", items: { type: "string" } },
                                        disablePropagationCheck: { type: "boolean" },
                                    },
                                },
                                httpChallenge: { type: "object", properties: { entryPoint: { type: "string" } } },
                                tlsChallenge: { type: "object" },
                            },
                        },
                    },
                    additionalProperties: false,
                },
            },
        },
        entryPoints: {
            type: "object",
            patternProperties: {
                "[a-zA-Z0-9-_]+": {
                    type: "object",
                    properties: {
                        address: { type: "string" },
                        transport: {
                            type: "object",
                            properties: {
                                lifeCycle: {
                                    type: "object",
                                    properties: {
                                        requestAcceptGraceTimeout: { type: "string" },
                                        graceTimeOut: { type: "string" },
                                    },
                                },
                                respondingTimeouts: {
                                    type: "object",
                                    properties: {
                                        readTimeout: { type: "string" },
                                        writeTimeout: { type: "string" },
                                        idleTimeout: { type: "string" },
                                    },
                                },
                            },
                        },
                        proxyProtocol: {
                            type: "object",
                            properties: {
                                insecure: { type: "boolean" },
                                trustedIPs: { type: "array", items: { type: "string" } },
                            },
                        },
                        forwardedHeaders: {
                            type: "object",
                            properties: {
                                insecure: { type: "boolean" },
                                trustedIPs: { type: "array", items: { type: "string" } },
                            },
                        },
                        http: {
                            type: "object",
                            properties: {
                                redirections: {
                                    type: "object",
                                    properties: {
                                        entryPoint: {
                                            type: "object",
                                            properties: {
                                                to: { type: "string" },
                                                scheme: { type: "string" },
                                                permanent: { type: "boolean" },
                                                priority: { type: "integer" },
                                            },
                                        },
                                    },
                                },
                                middlewares: { type: "array", items: { type: "string" } },
                                tls: {
                                    type: "object",
                                    properties: {
                                        options: { type: "string" },
                                        certResolver: { type: "string" },
                                        domains: {
                                            type: "array",
                                            items: {
                                                type: "object",
                                                properties: {
                                                    main: { type: "string" },
                                                    sans: { type: "array", items: { type: "string" } },
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                        http2: { type: "object", properties: { maxConcurrentStreams: { type: "integer" } } },
                        http3: { type: "object", properties: { advertisedPort: { type: "integer" } } },
                        udp: { type: "object", properties: { timeout: { type: "string" } } },
                    },
                    additionalProperties: false,
                },
            },
        },
        experimental: {
            type: "object",
            properties: {
                kubernetesGateway: { type: "boolean" },
                http3: { type: "boolean" },
                hub: { type: "boolean" },
                plugins: {
                    type: "object",
                    patternProperties: {
                        "[a-zA-Z0-9-_]+": {
                            type: "object",
                            properties: { moduleName: { type: "string" }, version: { type: "string" } },
                            additionalProperties: false,
                        },
                    },
                },
                localPlugins: {
                    type: "object",
                    patternProperties: {
                        "[a-zA-Z0-9-_]+": {
                            type: "object",
                            properties: { moduleName: { type: "string" } },
                            additionalProperties: false,
                        },
                    },
                },
            },
            additionalProperties: false,
        },
        global: {
            type: "object",
            properties: { checkNewVersion: { type: "boolean" }, sendAnonymousUsage: { type: "boolean" } },
            additionalProperties: false,
        },
        hostResolver: {
            type: "object",
            properties: {
                cnameFlattening: { type: "boolean" },
                resolvConfig: { type: "string" },
                resolvDepth: { type: "integer" },
            },
            additionalProperties: false,
        },
        hub: {
            type: "object",
            properties: {
                tls: {
                    type: "object",
                    properties: {
                        insecure: { type: "boolean" },
                        ca: { type: "string" },
                        cert: { type: "string" },
                        key: { type: "string" },
                    },
                },
            },
            additionalProperties: false,
        },
        log: {
            type: "object",
            properties: {
                filePath: { type: "string" },
                format: { type: "string" },
                level: { type: "string" },
                noColor: { type: "boolean" },
                maxSize: { type: "integer" },
                maxBackups: { type: "integer" },
                maxAge: { type: "integer" },
                compress: { type: "boolean" },
            },
            additionalProperties: false,
        },
        metrics: {
            type: "object",
            properties: {
                prometheus: {
                    type: "object",
                    properties: {
                        buckets: { type: "array", items: { type: "number" } },
                        addEntryPointsLabels: { type: "boolean" },
                        addRoutersLabels: { type: "boolean" },
                        addServicesLabels: { type: "boolean" },
                        entryPoint: { type: "string" },
                        manualRouting: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                datadog: {
                    type: "object",
                    properties: {
                        address: { type: "string" },
                        pushInterval: { type: "string" },
                        addEntryPointsLabels: { type: "boolean" },
                        addRoutersLabels: { type: "boolean" },
                        addServicesLabels: { type: "boolean" },
                        prefix: { type: "string" },
                    },
                    additionalProperties: false,
                },
                statsD: {
                    type: "object",
                    properties: {
                        address: { type: "string" },
                        pushInterval: { type: "string" },
                        addEntryPointsLabels: { type: "boolean" },
                        addRoutersLabels: { type: "boolean" },
                        addServicesLabels: { type: "boolean" },
                        prefix: { type: "string" },
                    },
                    additionalProperties: false,
                },
                influxDB: {
                    type: "object",
                    properties: {
                        address: { type: "string" },
                        protocol: { type: "string" },
                        pushInterval: { type: "string" },
                        database: { type: "string" },
                        retentionPolicy: { type: "string" },
                        username: { type: "string" },
                        password: { type: "string" },
                        addEntryPointsLabels: { type: "boolean" },
                        addRoutersLabels: { type: "boolean" },
                        addServicesLabels: { type: "boolean" },
                        additionalLabels: { type: "object" },
                    },
                    additionalProperties: false,
                },
                influxDB2: {
                    type: "object",
                    properties: {
                        address: { type: "string" },
                        token: { type: "string" },
                        pushInterval: { type: "string" },
                        org: { type: "string" },
                        bucket: { type: "string" },
                        addEntryPointsLabels: { type: "boolean" },
                        addRoutersLabels: { type: "boolean" },
                        addServicesLabels: { type: "boolean" },
                        additionalLabels: { type: "object" },
                    },
                    additionalProperties: false,
                },
            },
            additionalProperties: false,
        },
        pilot: {
            type: "object",
            properties: { token: { type: "string" }, dashboard: { type: "boolean" } },
            additionalProperties: false,
        },
        ping: {
            type: "object",
            properties: {
                entryPoint: { type: "string" },
                manualRouting: { type: "boolean" },
                terminatingStatusCode: { type: "integer" },
            },
            additionalProperties: false,
        },
        providers: {
            type: "object",
            properties: {
                providersThrottleDuration: { type: "string" },
                docker: {
                    type: "object",
                    properties: {
                        allowEmptyServices: { type: "boolean" },
                        constraints: { type: "string" },
                        defaultRule: { type: "string" },
                        endpoint: { type: "string" },
                        exposedByDefault: { type: "boolean" },
                        httpClientTimeout: { type: "integer" },
                        network: { type: "string" },
                        swarmMode: { type: "boolean" },
                        swarmModeRefreshSeconds: { type: "string" },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                        useBindPortIP: { type: "boolean" },
                        watch: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                file: {
                    type: "object",
                    properties: {
                        directory: { type: "string" },
                        watch: { type: "boolean" },
                        filename: { type: "string" },
                        debugLogGeneratedTemplate: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                marathon: {
                    type: "object",
                    properties: {
                        constraints: { type: "string" },
                        trace: { type: "boolean" },
                        watch: { type: "boolean" },
                        endpoint: { type: "string" },
                        defaultRule: { type: "string" },
                        exposedByDefault: { type: "boolean" },
                        dcosToken: { type: "string" },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                        dialerTimeout: { type: "string" },
                        responseHeaderTimeout: { type: "string" },
                        tlsHandshakeTimeout: { type: "string" },
                        keepAlive: { type: "string" },
                        forceTaskHostname: { type: "boolean" },
                        basic: {
                            type: "object",
                            properties: {
                                httpBasicAuthUser: { type: "string" },
                                httpBasicPassword: { type: "string" },
                            },
                            additionalProperties: false,
                        },
                        respectReadinessChecks: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                kubernetesIngress: {
                    type: "object",
                    properties: {
                        endpoint: { type: "string" },
                        token: { type: "string" },
                        certAuthFilePath: { type: "string" },
                        namespaces: { type: "array", items: { type: "string" } },
                        labelSelector: { type: "string" },
                        ingressClass: { type: "string" },
                        throttleDuration: { type: "string" },
                        allowEmptyServices: { type: "boolean" },
                        allowExternalNameServices: { type: "boolean" },
                        ingressEndpoint: {
                            type: "object",
                            properties: {
                                ip: { type: "string" },
                                hostname: { type: "string" },
                                publishedService: { type: "string" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                kubernetesCRD: {
                    type: "object",
                    properties: {
                        endpoint: { type: "string" },
                        token: { type: "string" },
                        certAuthFilePath: { type: "string" },
                        namespaces: { type: "array", items: { type: "string" } },
                        allowCrossNamespace: { type: "boolean" },
                        allowExternalNameServices: { type: "boolean" },
                        labelSelector: { type: "string" },
                        ingressClass: { type: "string" },
                        throttleDuration: { type: "string" },
                        allowEmptyServices: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                kubernetesGateway: {
                    type: "object",
                    properties: {
                        endpoint: { type: "string" },
                        token: { type: "string" },
                        certAuthFilePath: { type: "string" },
                        namespaces: { type: "array", items: { type: "string" } },
                        labelSelector: { type: "string" },
                        throttleDuration: { type: "string" },
                    },
                    additionalProperties: false,
                },
                rest: { type: "object", properties: { insecure: { type: "boolean" } }, additionalProperties: false },
                rancher: {
                    type: "object",
                    properties: {
                        constraints: { type: "string" },
                        watch: { type: "boolean" },
                        defaultRule: { type: "string" },
                        exposedByDefault: { type: "boolean" },
                        enableServiceHealthFilter: { type: "boolean" },
                        refreshSeconds: { type: "integer" },
                        intervalPoll: { type: "boolean" },
                        prefix: { type: "string" },
                    },
                    additionalProperties: false,
                },
                consulCatalog: {
                    type: "object",
                    properties: {
                        constraints: { type: "string" },
                        prefix: { type: "string" },
                        refreshInterval: { type: "string" },
                        requireConsistent: { type: "boolean" },
                        stale: { type: "boolean" },
                        cache: { type: "boolean" },
                        exposedByDefault: { type: "boolean" },
                        defaultRule: { type: "string" },
                        connectAware: { type: "boolean" },
                        connectByDefault: { type: "boolean" },
                        serviceName: { type: "string" },
                        namespace: { type: "string" },
                        namespaces: { type: "array", items: { type: "string" } },
                        watch: { type: "boolean" },
                        endpoint: {
                            type: "object",
                            properties: {
                                address: { type: "string" },
                                scheme: { type: "string" },
                                datacenter: { type: "string" },
                                token: { type: "string" },
                                endpointWaitTime: { type: "string" },
                                tls: {
                                    type: "object",
                                    properties: {
                                        ca: { type: "string" },
                                        caOptional: { type: "boolean" },
                                        cert: { type: "string" },
                                        key: { type: "string" },
                                        insecureSkipVerify: { type: "boolean" },
                                    },
                                    additionalProperties: false,
                                },
                                httpAuth: {
                                    type: "object",
                                    properties: { username: { type: "string" }, password: { type: "string" } },
                                    additionalProperties: false,
                                },
                            },
                            additionalProperties: false,
                        },
                    },
                },
                nomad: {
                    type: "object",
                    properties: {
                        constraints: { type: "string" },
                        prefix: { type: "string" },
                        refreshInterval: { type: "string" },
                        stale: { type: "boolean" },
                        exposedByDefault: { type: "boolean" },
                        defaultRule: { type: "string" },
                        namespace: { type: "string" },
                        endpoint: {
                            type: "object",
                            properties: {
                                address: { type: "string" },
                                region: { type: "string" },
                                token: { type: "string" },
                                endpointWaitTime: { type: "string" },
                                tls: {
                                    type: "object",
                                    properties: {
                                        ca: { type: "string" },
                                        caOptional: { type: "boolean" },
                                        cert: { type: "string" },
                                        key: { type: "string" },
                                        insecureSkipVerify: { type: "boolean" },
                                    },
                                    additionalProperties: false,
                                },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                ecs: {
                    type: "object",
                    properties: {
                        constraints: { type: "string" },
                        exposedByDefault: { type: "boolean" },
                        ecsAnywhere: { type: "boolean" },
                        refreshSeconds: { type: "integer" },
                        defaultRule: { type: "string" },
                        clusters: { type: "array", items: { type: "string" } },
                        autoDiscoverClusters: { type: "boolean" },
                        region: { type: "string" },
                        accessKeyID: { type: "string" },
                        secretAccessKey: { type: "string" },
                    },
                    additionalProperties: false,
                },
                consul: {
                    type: "object",
                    properties: {
                        rootKey: { type: "string" },
                        endpoints: { type: "array", items: { type: "string" } },
                        token: { type: "string" },
                        namespace: { type: "string" },
                        namespaces: { type: "array", items: { type: "string" } },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                etcd: {
                    type: "object",
                    properties: {
                        rootKey: { type: "string" },
                        endpoints: { type: "array", items: { type: "string" } },
                        username: { type: "string" },
                        password: { type: "string" },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                zooKeeper: {
                    type: "object",
                    properties: {
                        rootKey: { type: "string" },
                        endpoints: { type: "array", items: { type: "string" } },
                        username: { type: "string" },
                        password: { type: "string" },
                    },
                    additionalProperties: false,
                },
                redis: {
                    type: "object",
                    properties: {
                        rootKey: { type: "string" },
                        endpoints: { type: "array", items: { type: "string" } },
                        username: { type: "string" },
                        password: { type: "string" },
                        db: { type: "integer" },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                http: {
                    type: "object",
                    properties: {
                        endpoint: { type: "string" },
                        pollInterval: { type: "string" },
                        pollTimeout: { type: "string" },
                        tls: {
                            type: "object",
                            properties: {
                                ca: { type: "string" },
                                caOptional: { type: "boolean" },
                                cert: { type: "string" },
                                key: { type: "string" },
                                insecureSkipVerify: { type: "boolean" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                plugin: { type: "object", patternProperties: { "[a-zA-Z0-9-_]+": { type: "object" } } },
            },
        },
        serversTransport: {
            type: "object",
            properties: {
                insecureSkipVerify: { type: "boolean" },
                rootCAs: { type: "array", items: { type: "string" } },
                maxIdleConnsPerHost: { type: "integer" },
                forwardingTimeouts: {
                    type: "object",
                    properties: {
                        dialTimeout: { type: "string" },
                        responseHeaderTimeout: { type: "string" },
                        idleConnTimeout: { type: "string" },
                    },
                    additionalProperties: false,
                },
            },
            additionalProperties: false,
        },
        tracing: {
            type: "object",
            properties: {
                serviceName: { type: "string" },
                spanNameLimit: { type: "integer" },
                jaeger: {
                    type: "object",
                    properties: {
                        samplingServerURL: { type: "string" },
                        samplingType: { type: "string" },
                        samplingParam: { type: "integer" },
                        localAgentHostPort: { type: "string" },
                        gen128Bit: { type: "boolean" },
                        propagation: { type: "string" },
                        traceContextHeaderName: { type: "string" },
                        disableAttemptReconnecting: { type: "boolean" },
                        collector: {
                            type: "object",
                            properties: {
                                endpoint: { type: "string" },
                                user: { type: "string" },
                                password: { type: "string" },
                            },
                            additionalProperties: false,
                        },
                    },
                    additionalProperties: false,
                },
                zipkin: {
                    type: "object",
                    properties: {
                        httpEndpoint: { type: "string" },
                        sameSpan: { type: "boolean" },
                        id128Bit: { type: "boolean" },
                        sampleRate: { type: "integer" },
                    },
                    additionalProperties: false,
                },
                datadog: {
                    type: "object",
                    properties: {
                        localAgentHostPort: { type: "string" },
                        globalTag: { type: "string" },
                        globalTags: {
                            type: "object",
                            description: "Sets a list of key:value tags on all spans.",
                            patternProperties: { "[a-zA-Z0-9-_]+": { type: "string" } },
                        },
                        debug: { type: "boolean" },
                        prioritySampling: { type: "boolean" },
                        traceIDHeaderName: { type: "string" },
                        parentIDHeaderName: { type: "string" },
                        samplingPriorityHeaderName: { type: "string" },
                        bagagePrefixHeaderName: { type: "string" },
                    },
                    additionalProperties: false,
                },
                instana: {
                    type: "object",
                    properties: {
                        localAgentHost: { type: "string" },
                        localAgentPort: { type: "integer" },
                        logLevel: { type: "string" },
                        enableAutoProfile: { type: "boolean" },
                    },
                    additionalProperties: false,
                },
                haystack: {
                    type: "object",
                    properties: {
                        localAgentHost: { type: "string" },
                        localAgentPort: { type: "integer" },
                        globalTag: { type: "string" },
                        traceIDHeaderName: { type: "string" },
                        parentIDHeaderName: { type: "string" },
                        spanIDHeaderName: { type: "string" },
                        baggagePrefixHeaderName: { type: "string" },
                    },
                    additionalProperties: false,
                },
                elastic: {
                    type: "object",
                    properties: {
                        serverURL: { type: "string" },
                        secretToken: { type: "string" },
                        serviceEnvironment: { type: "string" },
                    },
                    additionalProperties: false,
                },
            },
            additionalProperties: false,
        },
    },
    type: "object",
});
