
# Palm Node Migration to Polygon Edge

Palm network is being transitioned from Besu client to Polygon Edge client. As part of the migration, it is required to configure
a stop block in existing Besu validators so that Besu clients will stop validating blocks. 

| Network | Transition Block | Transition Date | Besu Update Date  |
|---------|------------------|-----------------|-------------------|
| mainnet |      ?           |   2023-10-23    | before 2023-10-22 |
| testnet |    14223600      |   2023-10-02    | before 2023-10-01 |


## Update Besu Validator Nodes

Existing validators need to be updated with a forked binary available at [https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz](https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz). Also additional configuration parameters need to be set.

Update the inventory configuration for the Besu validator nodes
[playbooks/inventories/prd.yaml](playbooks/inventories/prd.yaml)
```yaml
all:
  hosts:
    # validator node
    1.2.3.4:
      # Set the fork block. Same block value must be set for all validators
      besu_cmdline_args:
        - "--miner-stop-block=99999999"
        - "--sync-stop-block=99999999"

  vars:
    # Override the default binary location for all nodes
    besu_download_url: "https://github.com/ConsenSys-Palm/palm-besu/releases/download/22.7.4/besu-22.7.4.tar.gz"
```
Run Ansible playbook to update the nodes
```bash
cd playbooks

# Example command updates UAT environment nodes
./update_nodes.sh uat 22.7.4
```

After the successful run of Ansible playbook, validator nodes should be updated with the new binary and two command line parameters configured in Besu Systemd file.

```bash
grep "^ExecStart" /etc/systemd/system/besu.service

# Command line aruments --miner-stop-block and --sync-stop-block should be appended to start command with the appropriate block number
ExecStart=/bin/sh -c "/opt/besu/current/bin/besu --config-file=/etc/besu/config.toml --miner-stop-block=99999999 --sync-stop-block=99999999 >> /var/log/besu/besu.log 2>&1"`
```

## Verification
Use following to verify the correct binary and configuration has been installed.

```bash
# Verify Besu binary
cksum /opt/besu/current/bin/besu
1500358826 16509 /opt/besu/current/bin/besu

# Verify configuration has been added to Besu service file
grep "^ExecStart" /etc/systemd/system/besu.service
ExecStart=/bin/sh -c "/opt/besu/current/bin/besu --config-file=/etc/besu/config.toml --miner-stop-block=99999999 --sync-stop-block=99999999 >> /var/log/besu/besu.log 2>&1"
```