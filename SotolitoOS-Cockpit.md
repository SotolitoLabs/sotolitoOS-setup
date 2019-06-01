# Sotolito OS Web UI

## Single Node
We use cockpit and podman for single node

### Cockpit

We use CentOS cockpit.

```
# systemctl enable cockpit
# systemctl enable cockpit.socket
# systemctl start cockpit.socket
# systemctl start cockpit
```

Open Ports

```
# firewall-cmd --add-service=cockpit --permanent
# firewall-cmd --reload

```

### Cockpit Podman

CentOS 32 bit does not have the cockpit-podman package, we'll use it from source.


