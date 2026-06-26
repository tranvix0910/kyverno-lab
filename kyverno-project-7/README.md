# Project 7 – Full-stack DevSecOps: Terraform + CI/CD + GitOps + Kyverno

## 1. Core Concepts

Project 7 is the final and most comprehensive milestone. In this project, we combine the **4 pillars** of Modern Infrastructure into a fully automated End-to-End Pipeline:

1. **IaC (Infrastructure as Code) - Terraform:** Automates the creation of hardware infrastructure (VPC, Cluster) and core platforms.
2. **GitOps - ArgoCD:** Uses Git as the Single Source of Truth. All configuration changes must be pulled automatically from Git to the Cluster.
3. **CI/CD (Continuous Integration) - GitHub Actions:** Verifies configurations, scans for vulnerabilities, and ensures infrastructure code safety before deployment.
4. **Policy-as-Code - Kyverno:** Acts as the comprehensive "Security Guard", operating on both fronts:
   - **Shift-Left:** Scans Terraform JSON plans directly on Pull Requests using Kyverno JSON CLI.
   - **Runtime:** Protects the Kubernetes Cluster via Webhooks (Validate, Mutate, Generate, Cleanup, Image Verify).

---

## 2. System Architecture (Mono-repo)

The system is organized into a Mono-repo structure with clear directories for Separation of Duties:

- `terraform/`: Contains Terraform source code (Creates AWS EKS).
- `policies/tf-policies/`: Contains Kyverno rules (JSON mode) to validate Terraform plan files.
- `policies/k8s-policies/`: Contains the most comprehensive Kyverno rules for Kubernetes (Verify Registry, Mutate, Generate, Cleanup, Validate).
- `apps/`: Contains sample applications and `PolicyException` files.
- `argocd/`: GitOps ArgoCD configuration using the App-of-Apps pattern.
- `.github/workflows/`: Contains CI scripts.

### Architecture Flow:

1. **Infrastructure CI:** Developer creates a PR for Terraform code -> GitHub Actions runs `terraform plan` -> converts to JSON -> Kyverno JSON CLI validates it against `tf-policies`.

2. **GitOps Deployment:** Once merged, ArgoCD automatically syncs `policies` (Wave 1) first, then syncs `apps` (Wave 2) to prevent Race Conditions.

3. **Admission Control:** Kyverno Webhook intercepts App deployments, verifies the Image Registry, injects secrets, generates NetworkPolicies, and ensures labels are present.

---

## 3. Advanced Kyverno Features Utilized

We use all of Kyverno's most powerful features:

1. **JSON Payload Validation:** Scanning Terraform plans directly without needing third-party tools like Checkov.

2. **Validating Policy:** Restricts Image Registries and strictly prohibits the `:latest` tag. Enforces the `cost-center` label.

3. **Mutating Policy:** Automatically injects security annotations (`security.company.com/managed`) into Pods.

4. **Generating Policy:** Automatically generates a default-deny `NetworkPolicy` for every newly created Namespace.

5. **Cleanup Policy:** Automatically cleans up completed Pods after 1 hour to free up resources.

6. **PolicyException CRD:** Safely bypasses security rules for specific applications (e.g., allowing `test-app` to bypass the registry check) without weakening the entire cluster's security posture.

---

## 4. Deep Dive Test Cases

Follow these step-by-step instructions to experience the combined power of GitOps and Kyverno.

### Test Case 1: Shift-Left CI (Block errors on PR)

**Goal:** Prove the "Shift-Left" philosophy - catching misconfigurations right at the coding phase before they reach the infrastructure.

**Steps:**
1. **Create a New Branch:** Simulate a Developer workflow.
   ```bash
   git checkout -b feature-test-ci
   ```
2. **Intentional Misconfiguration:** Open `terraform/main.tf` and ensure `endpoint_public_access = true` is set, exposing the EKS cluster to the public Internet.
3. **Push & PR:** Commit and push the code, then create a Pull Request to `master`.
4. **Observe CI Pipeline:**
   - GitHub Actions automatically triggers `infra-ci.yaml`.
   - It runs `kyverno-json scan` against the Terraform plan using `policies/tf-policies/check-eks-public.yaml`.
   - **Expected Result:** The PR Check fails (Exit code > 0) with a clear message: *"Public access to EKS cluster endpoint must be set to false"*. The vulnerable infrastructure is blocked entirely!

### Test Case 2: GitOps Sync & Admission Block (Kyverno as the Final Gatekeeper)

**Goal:** Simulate a scenario where a flawed configuration bypasses CI (e.g., Force Merge) and see how Kyverno blocks it at the Cluster level.

**Steps:**
1. **Force Merge Bad Code:** Force merge `apps/bad-app.yaml` (which lacks labels and uses the `latest` tag) into `master`.
2. **ArgoCD Sync:** ArgoCD detects the new file and attempts to create the Pod in Kubernetes.
3. **Kyverno Webhook Intervenes:**
   - Before the Pod is written to `etcd`, Kyverno Admission Controller intercepts the request.
   - It evaluates the Pod against `verify-image-source` and `require-cost-center` policies.
4. **Observe ArgoCD Status:**
   - ArgoCD shows the app as **OutOfSync** and **Missing**.
   - The Sync Status reveals Kyverno's denial message: *"You must provide the 'cost-center' label"* and *"The ':latest' tag is strictly prohibited"*.

### Test Case 3: Controlled Exceptions with PolicyException

**Goal:** Real-world security needs flexibility. We need to allow a specific app to bypass strict rules legally and traceably.

**Steps:**
1. **The Barrier:** `verify-image-source` policy strictly requires images from `registry.tranvix.click/*` and blocks `:latest`.
2. **The Exception Request:** The file `apps/exception.yaml` explicitly grants an exception to Pods named `test-app-*` to bypass the registry and tag checks.
3. **Observe the Difference:**
   - When ArgoCD deploys a valid app matching the exception, Kyverno acknowledges the `PolicyException` and allows it.
   - If a hacker tries to name their pod `hacker-app` and use `:latest`, it will be ruthlessly blocked because the name does not match the approved exception pattern!
   - **Conclusion:** Robust security without extreme rigidity. All exceptions are clearly documented as Code.