<!-- markdownlint-disable MD033 -->

<h1 align="center">
  Nexus · Raspberry Pi <sub>(Nex · RPi)</sub>
</h1>

<h4 align="center">Nex·RPi - Mission-critical services</h4>

<div align="center">

[![License](https://img.shields.io/badge/License-Apache_2.0-blue?logo=git\&logoColor=white\&logoWidth=20)](../../LICENSE)

<!-- trunk-ignore-begin(markdown-link-check/404) -->

<a href="#ℹ%EF%B8%8F-about">About</a> · <a href="#%EF%B8%8F-mission-critical-services">Services</a> · <a href="#-how-to-use--how-to-develop-on-it">How to use</a> · <a href="#-disaster-recovery-plan-drp">Disaster Recovery Plan (DRP)</a> · <a href="#%EF%B8%8F-roadmap">Roadmap</a> · <a href="#%EF%B8%8F-license">License</a>

<!-- trunk-ignore-end(markdown-link-check/404) -->

</div>

***

<!-- markdownlint-enable MD033 -->

## ℹ️ About

Nex·RPi is a project that aims to transform a Raspberry Pi 5 into the most critical component of my homelab.
This project integrates several essential components to allow other projects to be deployed and managed securely,
without\[^1] the need of third-party services.

## 🛠️ Mission-Critical services

![Architecture diagram](./assets/architecture.svg)

### 🌐 Networking

* **DNS based on [AdGuard Home](https://adguard.com/en/adguard-home/overview.html)**: Serves as a local DNS cache to
  speed up DNS resolution, block ads and trackers, and provide local services DNS records if the internet is down.

  **Why is it mission-critical?** It ensures that, even if the internet is down, I can still access local services using
  their DNS names like we do normally.

* **VPN based on [TailScale](https://tailscale.com/)**: Allows access to hosted services from anywhere and manages SSH
  access to devices on the cloud (AWS, Hetzner, etc).

  **Why is it mission-critical?** It allows me to access my homelab services from anywhere securely and access cloud-based
  services without managing SSH keys or a PKI.

### 🔐 Authentication and Authorization

* **LDAP based on [yaLDAP](https://github.com/chezmoi-sh/yaldap/tree/main)**: Provides centralized user management,
  LDAP-compatible service, and is easy to deploy with no feature bloat and static configuration.

  **Why is it mission-critical?** It provides a centralized user management system that can be used by other services
  like SSO and more.

* **SSO based on [Authelia](https://www.authelia.com/)**: Centralized authentication with 2FA, SSO, easy deployment,
  and backed by the previous LDAP.

  **Why is it mission-critical?** It provides a centralized authentication system that can be used by other services
  in the homelab.

### 🗄️ Storage

* **S3 compatible storage based on [MinIO](https://min.io/)**: Stores Pulumi states, but can also be used to store
  metrics and logs.

  ❗**Why is it mission-critical?** Storing Pulumi states makes it essential for the infrastructure to work correctly and
  nothing can be deployed without.

* **Registry based on [zot registry](https://zotregistry.dev)**: Stores Docker images locally.

  ❗**Why is it mission-critical?** All Docker images used by other services are in this registry, and without it, no
  service can be deployed.

* **Secrets vault based on [kubevault](https://github.com/chezmoi-sh/kubevault)**: Stores all secrets used by other services in a secure way.

  **Why is it mission-critical?** It ensures that all secrets are stored securely and can be accessed by services that
  need them with the right ACLs.

### 📦 Others

* **NUT server**: Monitors UPS status and battery level, ideal for Raspberry Pi due to its low power consumption.

  **Why is it mission-critical?** It ensures that all servers can shut down gracefully in case of a power outage.

* **Home dashboard based on [homepage](https://gethomepage.dev/latest/)**: Provides a page with all services and their
  status.

  **Why is it mission-critical?** This is not mission-critical, but it covenient to have a single page with all services
  hosted on the device that must not be shut down.

## 🚀 How to use / How to develop on it

> \[!WARNING]
> This project is still in development and not ready for use

## 💀 Disaster Recovery Plan (DRP)

In case of a disaster, the following steps should be taken:

> \[!WARNING]
> This part depends on how the project is deployed... so until I found a way to deploy it, this part is not yet ready.

## 🗺️ Roadmap

* \[X] List all services that should be deployed on this project.
* \[X] Create a diagram of the architecture.
* \[ ] Wait until I found a way to manage all services deployed on my Homelab.

## 🛡️ License

This repository is licensed under the [Apache-2.0](../../LICENSE).

> \[!CAUTION]
> This is a personal project intended for my own use. Feel free to explore and use the code,
> but please note that it comes with no warranties or guarantees. Use it at your own risk.

\[^1]:
Except for TailScale and SMTP services, which are used for external communication. However, these services are
optional and everything *should* work without them.

\[^2]:
This will force to use a local docker registry to deploy the services. **Make sure to be able to access the
registry from the remote device.**