# Sotolito OS Web UI

## Single Node
We use cockpit and podman for single node

### Cockpit

We use CentOS cockpit.

```
# systemctl enable cockpit
```

Open Ports

```
# firewall-cmd --add-service=cockpit
# firewall-cmd --add-service=cockpit --permanent

```

### Cockpit Podman

CentOS 32 bit does not have the cockpit-podman package, we'll use it from source.


