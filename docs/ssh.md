# SSH Access

For all servers - add your public key to Vault under `Projects/iac/ssh` key `authorized_keys` and run terraform apply to update the servers.

## RKE2 Cluster Nodes

Terraform creates an ssh config file at `/etc/hasadna/rke2_ssh_config`, modify your `~/.ssh/config` to include it:

```
echo "Include /etc/hasadna/rke2_ssh_config" >> ~/.ssh/config
```

You can now ssh to rke2 nodes like this:

```
ssh hasadna-rke2-worker1
```
