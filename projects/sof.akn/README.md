<!-- markdownlint-disable MD033 -->

<h1 align="center">
  「 火霊 」 <sub>(Spirit Of Fire)</sub>
</h1>

<h4 align="center">SoF - Home Services Platform</h4>

<div align="center">

[![License](https://img.shields.io/badge/License-Apache_2.0-blue?logo=git\&logoColor=white\&logoWidth=20)](../../LICENSE)

<!-- trunk-ignore-begin(markdown-link-check/404) -->

<a href="#ℹ%EF%B8%8F-about">About</a> · <a href="#%EF%B8%8F-architecture">Architecture</a> · <a href="#-how-to-use--how-to-develop-on-it">How to use</a> · <a href="#-recovery--bootstrap">Recovery</a> · <a href="#%EF%B8%8F-roadmap">Roadmap</a> · <a href="#%EF%B8%8F-license">License</a>

<!-- trunk-ignore-end(markdown-link-check/404) -->

</div>

***

## ℹ️ About

Spirit of Fire[^1] is a personal self-hosted platform for home services, designed to provide a complete ecosystem for media management, life organization, and automation. The platform runs on a Kubernetes cluster and is accessible through both local network and VPN, allowing secure access to services from anywhere while maintaining control over data and infrastructure.

## 🏗️ Architecture

![Architecture diagram](./assets/architecture.svg)

### 🏗️ Platform Infrastructure

* **[Cilium](https://cilium.io/)**: Container Network Interface (CNI). <br/>
  Advanced networking, security policies, and observability for Kubernetes clusters.

* **[Tailscale](https://tailscale.com/)**: Mesh VPN network. <br/>
  Zero-config VPN mesh for secure remote access to the entire platform.

* **[External Secrets](https://external-secrets.io/)**: Secrets management operator. <br/>
  Kubernetes operator that integrates external secret management systems.

* **[External DNS](https://github.com/kubernetes-sigs/external-dns)**: DNS automation. <br/>
  Automatically configures DNS records for Kubernetes services.

* **[cert-manager](https://cert-manager.io/)**: Certificate automation. <br/>
  Automatic provisioning and management of TLS certificates in Kubernetes.

* **[kgateway](https://github.com/kgateway-dev/kgateway)**: Cloud-native API Gateway. <br/>
  Envoy-based gateway with Kubernetes Gateway API support, optimized for service routing.

* **[Longhorn](https://longhorn.io/)**: Distributed block storage. <br/>
  Lightweight, reliable, and powerful distributed block storage system for Kubernetes.

* **[CloudNativePG](https://cloudnativepg.io/)**: PostgreSQL operator. <br/>
  Comprehensive platform designed to seamlessly manage PostgreSQL databases within Kubernetes environments.

### 📺 Media Services

* **[Jellyfin](https://jellyfin.org/)**: Media server. <br/>
  Volunteer-built media solution that puts you in control of your media.

* **[Jellyseerr](https://github.com/Fallenbagel/jellyseerr)**: Media requests. <br/>
  Free and open source software application for managing requests for media libraries.

### 🏠 Life Management

* **[Actual Budget](https://actualbudget.com/)**: Budget management. <br/>
  Personal finance app that helps you track your spending and save money.

* **[Paperless-ngx](https://docs.paperless-ngx.com/)**: Document management. <br/>
  Document management system to store, search and share documents.

### 📦 Others

* **[Linkding](https://github.com/sissbruecker/linkding)**: Bookmarking service. <br/>
  Self-hosted bookmarking and link aggregation service.

* **[Atuin](https://docs.atuin.sh/)**: Shell history sync. <br/>
  Encrypted shell history sync, storing all your shell commands in one place.

* **[TaskChampion](https://github.com/GothenburgBitFactory/taskchampion-sync-server)**: Task management sync. <br/>
  Sync server for TaskWarrior, a modern task management system.

## 🚀 How to use / How to develop on it

This project uses [ArgoCD](https://argoproj.github.io/cd/) for GitOps-based deployment and [Kustomize](https://kustomize.io/) for configuration management. Here's how to work with it:

## 💀 Disaster Recovery Plan (DRP)

The recovery process is largely automated through the `amiya.akn` project, which hosts ArgoCD and automatically bootstraps any Kubernetes clusters it detects in the Tailscale mesh.

### Automated Recovery Process

> \[!NOTE]
> If the system cannot be managed using Talosctl, reboot on a live CD

1. **Reset/Reinstall Talos OS**:
   ```bash
   # If the system is still accessible
   talosctl reset --nodes $TALOS_NODE_IP --endpoints $TALOS_NODE_IP --graceful=false --reboot

   # Otherwise, reinstall from ISO/PXE and bootstrap the cluster
   talosctl bootstrap --nodes $TALOS_NODE_IP --endpoints $TALOS_NODE_IP
   ```

2. **Install Tailscale Operator** - the only manual step required:
   ```bash
   # Install via Helm
   helm repo add tailscale https://pkgs.tailscale.com/helmcharts
   helm upgrade --install tailscale-operator tailscale/tailscale-operator \
     --namespace=tailscale --create-namespace \
     --set-string oauth.clientId="<OAuth client ID>" \
     --set-string oauth.clientSecret="<OAuth client secret>" \
     --wait
   ```

3. **Automatic Detection** - Once the cluster joins the Tailscale mesh, `amiya.akn` detects it automatically

4. **Auto-Bootstrap** - ArgoCD deploys all applications and configurations via GitOps

### Manual Verification

* Check cluster status: `kubectl get pods --all-namespaces`
* Verify Tailscale connectivity: `tailscale status`
* Confirm ArgoCD sync status in the `amiya.akn` console

> The entire platform is designed for zero-touch recovery once Tailscale is configured.

## 🗺️ Roadmap

<!-- trunk-ignore-begin(remark-lint/list-item-content-indent) -->

* [x] **Step 0**: Define project scope and architecture
  * [x] List all services to be deployed
  * [x] Create architecture diagram
* [ ] **Step 1**: Initial deployment
  * [ ] Deploy base infrastructure (Talos, Cilium)
  * [ ] Configure core services (External Secrets, DNS, cert-manager)
  * [ ] Deploy Longhorn for distributed storage
  * [ ] Deploy kgateway as API Gateway
* [ ] **Step 2**: Data Layer
  * [ ] Deploy CloudNativePG operator
  * [ ] Deploy PostgreSQL for application data
* [ ] **Step 3**: Services Deployment
  * [ ] Deploy media services (Jellyfin, Jellyseerr)
  * [ ] Deploy life management services (Actual Budget, Paperless-ngx)
  * [ ] Configure n8n for automation
  * [ ] Deploy Linkding for bookmarks
* [ ] **Step 4**: Security and Optimization
  * [ ] Implement network policies
  * [ ] Configure backup solutions
  * [ ] Optimize resource usage

<!-- trunk-ignore-end(remark-lint/list-item-content-indent) -->

## 🛡️ License

This repository is licensed under the [Apache-2.0](../../LICENSE).

> \[!CAUTION]
> This is a personal project intended for my own use. Feel free to explore and use the code,
> but please note that it comes with no warranties or guarantees. Use it at your own risk.

[^1]: The Spirit of Fire is a UNSC Phoenix-class colony ship from the Halo universe, known for its versatility and self-sufficiency. See [Halopedia](https://www.halopedia.org/UNSC_Spirit_of_Fire) for more information.
