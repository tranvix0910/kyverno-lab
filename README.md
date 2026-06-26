# Kyverno Projects Catalog

This repository contains a collection of 7 hands-on projects demonstrating various features, implementation patterns, and advanced use cases of Kyverno, the Kubernetes-native Policy-as-Code engine.

The catalog spans from basic automation to advanced GitOps integrations and full-stack DevSecOps pipelines.

---

## Projects Overview

### 1. Image Pull Secret Automation & Workload Standardization
- **Location:** [kyverno-project-1](file:///home/kubernetes/kyverno/kyverno-project-1/README.md)
- **Core Focus:** Automating registry credentials propagation and enforcing Pod baseline configuration standards.
- **Key Features:** Clones docker authentication Secrets dynamically, generates compliant ServiceAccounts, blocks container pulls from private registries that lack authorization credentials, and enforces CPU/RAM resource limits.

### 2. Pod Security & Network Baseline
- **Location:** [kyverno-project-2](file:///home/kubernetes/kyverno/kyverno-project-2/README.md)
- **Core Focus:** Establishing container runtime and network boundaries inside the cluster.
- **Key Features:** Restricts privileged access, host networking, and root filesystem writes. It automatically injects safe execution defaults (`runAsNonRoot: true`, `allowPrivilegeEscalation: false`) and automatically enforces namespace-level network isolation (default-deny).

### 3. Image Security: ImageValidatingPolicy + Attestation
- **Location:** [kyverno-project-3](file:///home/kubernetes/kyverno/kyverno-project-3/README.md)
- **Core Focus:** Verifying container image supply chain integrity using Sigstore/Cosign.
- **Key Features:** Verifies image signatures via keyless OIDC authentication, enforces presence of Software Bill of Materials (SBOM) and vulnerability scan attestations, and uses NamespacedImageValidatingPolicy to allow development teams to customize image security boundaries.

### 4. Automating "Ready-to-use" Namespaces with Generate Policy
- **Location:** [kyverno-project-4](file:///home/kubernetes/kyverno/kyverno-project-4/README.md)
- **Core Focus:** Seamlessly provisioning resources inside newly created Namespaces.
- **Key Features:** Automatically clones Secrets, provisions default configurations (ConfigMaps, NetworkPolicies), runs bulk distributions via looping (`foreach`), and applies policy updates retroactively to existing Namespaces.

### 5. Garbage Collection & Lifecycle: Automation with Cleanup Policy (DeletingPolicy)
- **Location:** [kyverno-project-5](file:///home/kubernetes/kyverno/kyverno-project-5/README.md)
- **Core Focus:** Managing the lifecycle and garbage collection of temporary or expired resources.
- **Key Features:** Cleans up completed Jobs, temporary test Pods, and expired Secrets/ConfigMaps using schedule-based policies (cron) and CEL time functions (`time.now()`).

### 6. GitOps & Policy-as-Code: Integrating Flux/ArgoCD and Kyverno
- **Location:** [kyverno-project-6](file:///home/kubernetes/kyverno/kyverno-project-6/README.md)
- **Core Focus:** Managing Kubernetes manifests and policies using Git as the Single Source of Truth.
- **Key Features:** Shift-left testing using Kyverno CLI (`kyverno apply`) in GitHub Actions workflows, ArgoCD synchronization patterns, and managing policy exemptions with the PolicyException CRD.

### 7. Full-stack DevSecOps: Terraform + CI/CD + GitOps + Kyverno
- **Location:** [kyverno-project-7](file:///home/kubernetes/kyverno/kyverno-project-7/README.md)
- **Core Focus:** The culmination of Kyverno features integrated into a full end-to-end DevSecOps pipeline.
- **Key Features:** Validating Terraform infrastructure plans via Kyverno JSON CLI before resources are created, deploying apps and policies using ArgoCD App-of-Apps, runtime admission webhook validation, and handling controlled exceptions.

---

## Shared Infrastructure Information

Across all projects, local registry and configuration references are aligned with the following environment standards:

- **Private Registry Host:** `registry.tranvix.click`
- **Security Protocols:** Keyless OIDC signing is verified using Github Actions workflow identities under the `tranvix0910` organization and Rekor public transparency logs (`rekor.sigstore.dev`).
