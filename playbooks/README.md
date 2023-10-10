
# Palm Migration to Polygon Edge
Palm nodes will be migrated from Besu binary to Polygon Edge binary. In order to facilitate this migration, Besu nodes must stop block validation at an agreed block so that Polygon Edge nodes can start validating blocks beyond the agreed block. Forked version of Besu binary has been released at [https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz](https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz) which need to be installed and updated with couple of configurations to allow the migration.

## Besu Command Line Parameters
These command line parameters need to be configured when running the forked Besu binary.
| Parameter              |        Value          |
|------------------------|-----------------------|
| --miner-stop-block     | Agreed block for fork |
| --sync-stop-block      | Agreed block for fork |


## Upgrade Validator Nodes
Follow the below instruction to update the Besu nodes which have been deployed using this GitHub repository with the Besu Ansible role.

Update the inventory file for the relevant environment (example prd.yaml)
[playbooks/inventories/prd.yaml](playbooks/inventories/prd.yaml)
```yaml
all:
  hosts:
    # validator node
    1.2.3.4:
      # Set the fork block. Same block value must be set for all validators
      besu_cmdline_args:
        - "--miner-stop-block=14191200"
        - "--sync-stop-block=14191200"

  vars:
    # Override the default binary location for all nodes
    besu_download_url: "https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz"
```

Run Ansible playbook to update the nodes
```bash
cd playbooks

# Example command updates UAT environment nodes
./update_nodes.sh prd 22.7.4
```

After the successful run of Ansible playbook, validator nodes should be updated with the new binary and two command line parameters configured in Besu Systemd file.

```bash
grep "^ExecStart" /etc/systemd/system/besu.service

# Command line aruments --miner-stop-block and --sync-stop-block should be appended to start command with the appropriate block number
ExecStart=/bin/sh -c "/opt/besu/current/bin/besu --config-file=/etc/besu/config.toml --miner-stop-block=14191200 --sync-stop-block=14191200 >> /var/log/besu/besu.log 2>&1"`
```

## Verification
Use following to verify the correct binary and configuration has been installed.

```bash
# Verify Besu binary
cksum /opt/besu/current/bin/besu
1500358826 16509 /opt/besu/current/bin/besu

# Verify configuration has been added to Besu service file
grep "^ExecStart" /etc/systemd/system/besu.service
ExecStart=/bin/sh -c "/opt/besu/current/bin/besu --config-file=/etc/besu/config.toml --miner-stop-block=14191200 --sync-stop-block=14191200 >> /var/log/besu/besu.log 2>&1"
```
