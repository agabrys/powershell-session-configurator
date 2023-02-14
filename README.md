# PowerShell Session Configurator

The `configure.ps1` script configures predefined tools in the current PowerShell session. Whenever the supported tool is missing, its configuration phase is ommited (no need to install all tools).

- [Usage](#usage)
- [PowerShell User Profile Integration](#powershell-user-profile-integration)
- [Tools](#tools)
  - [K3d](#k3d)
  - [Kubectl](#kubectl)
  - [Kubectx](#kubectx)

## Usage

Execute

```powershell
. .\configure.ps1
```

## PowerShell User Profile Integration

The `configure.ps1` script may be executed by the user's PowerShell profile file. Execute

```powershell
. .\profile-install.ps1
```

to add it or

```powershell
.\profile-uninstall.ps1
```

to remove it.

## Tools

### K3d

When [`k3d`](https://k3d.io/) is available on `$env:PATH`, the configurator enables the auto-completion feature.

### Kubectl

When [`kubectl`](https://kubernetes.io/docs/reference/kubectl/kubectl/) is available on `$env:PATH`, the configurator:

- enables the auto-completion feature
- adds the `k` alias

### Kubectx

When [`kubectx`](https://github.com/ahmetb/kubectx) is available on `$env:PATH`, the configurator enables the auto-completion feature.
