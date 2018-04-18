# mdsjip_infra
mdsjip Infra repository

## Homework-4 Introduction to GCP
### Bastion Host
You can connect to hosts in internal network using bastion host.


#### Shell one-liner
TL;DR: `ssh -A -J appuser@35.189.229.226 appuser@10.132.0.3`

Assuming you have 1 external IP address for bastion host and some internal host with specific IP address, you can do the following:

```shell
bastion_IP='35.189.229.226'; someinternalhost_IP='10.132.0.3'; user='appuser'; id_file="$HOME/.ssh/appuser"; [[ -z ${SSH_AGENT_PID+x} ]] && eval $(ssh-agent); ssh-add $id_file; ssh -A -J $user@$bastion_IP $user@$someinternalhost_IP
```

If you have openssh-client version prior to 7.3, you can use the ProxyCommand option:

```shell
bastion_IP='35.189.229.226'; someinternalhost_IP='10.132.0.3'; user='appuser'; id_file="$HOME/.ssh/appuser"; [[ -z ${SSH_AGENT_PID+x} ]] && eval $(ssh-agent); ssh-add $id_file; ssh -A -o ProxyCommand="ssh -W %h:%p $user@$bastion_IP" $user@$someinternalhost_IP
```

With even older clients you can use TTY allocation:

```shell
bastion_IP='35.189.229.226'; someinternalhost_IP='10.132.0.3'; user='appuser'; id_file="$HOME/.ssh/appuser"; [[ -z ${SSH_AGENT_PID+x} ]] && eval $(ssh-agent); ssh-add $id_file; ssh -A -tt $user@$bastion_IP ssh -tt $user@$someinternalhost_IP
```

#### Host Alias

If you want something shorter like this:
```shell
ssh someinternalhost
```
You can use SSH config file:

```shell
mkdir -p ~/.ssh
cat <<EOF >> ~/.ssh/config

# Connecting to internal hosts through the bastion host with external IP
Host bastion
  HostName 35.189.229.226
  Port 22
  User appuser
  IdentityFile ~/.ssh/appuser
  AddKeysToAgent yes

Host someinternalhost
  Hostname 10.132.0.3
  Port 22
  User appuser
  ProxyJump bastion
EOF
```
Or for older versions:

```shell
mkdir -p ~/.ssh
cat <<EOF >> ~/.ssh/config

# Connecting to internal hosts through bastion host with external IP
# For OpenSSH client versions prior to 7.3
Host bastion
  HostName 35.189.229.226
  Port 22
  User appuser
  IdentityFile ~/.ssh/appuser
  AddKeysToAgent yes

Host someinternalhost
  Hostname 10.132.0.3
  Port 22
  User appuser
  ProxyCommand ssh -W %h:%p bastion
EOF
```

### Connecting to someinternalhost over VPN

```
bastion_IP=35.189.229.226
someinternalhost_IP=10.132.0.3
```

You can use the following command for connection:
```shell
sudo openvpn --config cloud-bastion.ovpn
```
