# flux-with-helm

For this example we assume a scenario with two clusters: staging and production. The end goal is to leverage Flux and Kustomize to manage both clusters while minimizing duplicated declarations.
"The end goal is to leverage Flux and Kustomize to manage both clusters while minimizing duplicated declarations."
the meaning of "Kustomize" refers to the Kubernetes-native configuration management tool that allows you to:

✅ Customize Kubernetes YAML manifests without copying them.

🔍 What "Kustomize" is doing here:

You have common base configurations for your app (e.g., deployment.yaml, service.yaml).

You create overlays(custom versions) for each environment or cluster (e.g., dev, prod) with only the differences (e.g., image tags, replica count, resource limits).

Kustomize helps you reuse the base files and only apply what's different for each cluster — this avoids duplicating the whole YAML for every environment.

We will configure Flux to install, test and upgrade a demo app using HelmRepository and HelmRelease custom resources.Flux will monitor the Helm repository, and it will automatically upgrade the Helm releases to their latest chart version based on semver ranges.

SemVer means:

Semantic Versioning — written like this:

MAJOR.MINOR.PATCH → example: 1.2.3

It's a specific version:

1 → Major version (big changes)

2 → Minor version (new features, no breaking)

3 → Patch version (bug fixes)

``` >=1.2.3 is a SemVer Range or Constraint ```

This is not a version.

It’s a rule that means:

Allow versions that are greater than or equal to 1.2.3
(e.g., 1.2.4, 1.3.0, 2.0.0)

## Prerequisites

You will need a Kubernetes cluster version 1.28 or newer. For a quick local test, you can use Kubernetes kind. Any other Kubernetes setup will work as well though.

In order to follow the guide you'll need a GitHub account and a personal access token that can create repositories (check all permissions under repo).

Install the Flux CLI on macOS or Linux using Homebrew:

```brew install fluxcd/tap/flux```

Or install the CLI by downloading precompiled binaries using a Bash script:

```curl -s https://fluxcd.io/install.sh | sudo bash```

 ### Repository structure
The Git repository contains the following top directories:

- apps dir contains Helm releases with a custom configuration per cluster
- infrastructure dir contains common infra tools such as ingress-nginx and cert-manager
- clusters dir contains the Flux configuration per cluster
```
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── configs
│   └── controllers
└── clusters
    ├── production
    └── staging
```

### Applications
The apps configuration is structured into:

- apps/base/ dir contains namespaces and Helm release definitions
- apps/production/ dir contains the production Helm release values
- apps/staging/ dir contains the staging values
```
./apps/
├── base
│   └── podinfo
│       ├── kustomization.yaml
│       ├── namespace.yaml
│       ├── release.yaml
│       └── repository.yaml
├── production
│   ├── kustomization.yaml
│   └── podinfo-patch.yaml
└── staging
    ├── kustomization.yaml
    └── podinfo-patch.yaml
```

In apps/base/podinfo/ dir we have a Flux HelmRelease with common values for both clusters:

```
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo
  namespace: podinfo
spec:
  releaseName: podinfo
  chart:
    spec:
      chart: podinfo
      sourceRef:
        kind: HelmRepository
        name: podinfo
        namespace: flux-system
  interval: 50m
  values:
    ingress:
      enabled: true
      className: nginx
```

In apps/staging/ dir we have a Kustomize patch with the staging specific values:
```
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo
spec:
  chart:
    spec:
      version: ">=1.0.0-alpha"
  test:
    enable: true
  values:
    ingress:
      hosts:
        - host: podinfo.staging
```

Note that with  version: ">=1.0.0-alpha" we configure Flux to automatically upgrade the HelmRelease to the latest chart version including alpha, beta and pre-releases.

In apps/production/ dir we have a Kustomize patch with the production specific values:
```
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: podinfo
  namespace: podinfo
spec:
  chart:
    spec:
      version: ">=1.0.0"
  values:
    ingress:
      hosts:
        - host: podinfo.production
```
Note that with  version: ">=1.0.0" we configure Flux to automatically upgrade the HelmRelease to the latest stable chart version (alpha, beta and pre-releases will be ignored).





 
