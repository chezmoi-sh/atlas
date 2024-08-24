{{/*
  This files is used to bootstrap the values.yaml file for this Helm chart and all
  the templates that will be used to render the Kubernetes resources.

  NOTE: This is not currently in use, but it's here for reference purposes if I
        decide to use it in the future.
*/}}
{{ kubeversion "v1.30.0" }}
{{ metadata }}
{{ spec }}
{{ pod_template ("traefik" (container "traefik" "ghcr.io/chezmoi-sh/traefik")) }}
{{ scheduling }}
{{ autoscaling }}
{{ distruptionBudget }}
{{ service }}
