# -- Variables -----------------------------------------------------------------
kubernetes_configuration := env("KUBECONFIG", justfile_directory() / "../../.direnv/kubernetes/config")
kubernetes_context := kubernetes_host
kubernetes_host := "kubernetes.nr.chezmoi.sh"
kubernetes_applyset := replace_regex(blake3("kubevault/chezmoi.sh"), "[a-f0-9]{32}$", "")

kubectl := "kubectl --kubeconfig " + quote(kubernetes_configuration) + " --context " + quote(kubernetes_context)

[private]
@default:
  just --list --list-submodules


# -- Vault related tasks -------------------------------------------------------
[doc("Encrypts the kvstore")]
encrypt:
  @echo "Backing up kvstore.enc"
  @[[ ! -d kvstore.enc.bak ]] || (echo "🞪 kvstore.enc.bak already exists... Remove this folder before running again"; exit 1)
  @[[ -d kvstore.enc ]] && mv kvstore.enc kvstore.enc.bak || true
  @rm -rf kvstore.enc && mkdir --parent kvstore.enc
  @echo "Encrypting kvstore to kvstore.enc"
  @find kvstore -type f -exec sh -c '\
    echo "- Encrypting {}"; \
    mkdir -p "kvstore.enc/$(dirname "${1#kvstore/}")" \
    && sops encrypt --input-type yaml --output-type yaml "$1" > "kvstore.enc/${1#kvstore/}" \
  ' _ {} \;

[doc("Decrypts the kvstore.enc")]
decrypt:
  @rm -rf kvstore && mkdir --parent kvstore
  @echo "Decrypting kvstore.enc to kvstore"
  @find kvstore.enc -type f -exec sh -c '\
    echo "- Decrypting {}"; \
    mkdir -p "kvstore/$(dirname "${1#kvstore.enc/}")" \
    && sops decrypt --input-type yaml --output-type yaml "$1" > "kvstore/${1#kvstore.enc/}" \
  ' _ {} \;

[doc("Synchronizes the local kvstore with the remote on Kubernetes")]
sync *kubectl_opts="":
  @[[ -d kvstore ]] || (echo "🞪 kvstore does not exist... Run 'just decrypt' or 'just vault decrypt' first"; exit 1)
  @echo "Syncing kvstore to Kubernetes"
  @kubevault generate --vault-dir="{{ source_directory() }}" \
    | KUBECTL_APPLYSET=true \
      {{ kubectl }} apply --filename - \
      --prune --server-side --applyset="clusterapplysets.kubernetes.chezmoi.sh/{{ kubernetes_applyset }}" --force-conflicts \
      {{ kubectl_opts }}

[doc("Shows the diff of the kvstore changes")]
diff: decrypt
  @kubevault generate --vault-dir="{{ source_directory() }}" \
    | {{ kubectl }} diff --filename - --server-side \
  || true


# -- Kubernetes helper tasks ---------------------------------------------------
[private]
[doc("Generates the ClusterApplySet required follow which resources should be pruned")]
generate-applyset:
  #!/bin/env bash
  set -euo pipefail

  {{ kubectl }} create --filename - <<EOF
  apiVersion: kubernetes.chezmoi.sh/v1alpha1
  kind: ClusterApplySet
  metadata:
    annotations:
      applyset.kubernetes.io/tooling: kubectl/v1.31
      applyset.kubernetes.io/contains-group-kinds: ''
    labels:
      applyset.kubernetes.io/id: applyset-$(
        echo -n "{{ kubernetes_applyset }}..ClusterApplySet.kubernetes.chezmoi.sh" \
        | openssl dgst -sha256 -binary \
        | openssl base64 -A \
        | tr -d '=' | tr '/+' '_-'
      )-v1
    name: "{{ kubernetes_applyset }}"
  EOF
