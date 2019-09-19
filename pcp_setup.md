# PCP Configuration
PCP stands for: Performance CO-Pilot, it's a set of tools for monitoring
and metric recolection.

Most stuff works out of the box (log rotate, what to monitor, etc...)

## pmie Alarm Setup

*TODO: better explanation*

The pmie configuration for hosts is on: `/etc/pcp/pmie/control` and `/etc/pcp/pmie/control.d/`.
Each file in `/etc/pcp/pmie/control.d/` represents a host with it's rule file.


## References
* https://pcp.io/books/PCP_UAG/html/Z927039824sdc.html
