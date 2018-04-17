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

## Homework-5 Cloud Test Application
### TL;DR
Given specific project id, whole process can be done by this:
```shell
gcloud config set project otus-infra-197909
gcloud compute instances delete reddit-app --delete-disks=all --quiet --zone=europe-west1-b
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone europe-west1-b --metadata-from-file startup-script=startup-script.sh

gcloud compute firewall-rules delete default-puma-server --quiet
gcloud compute firewall-rules create default-puma-server --description=default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
```

### Shell scripts

To deploy test application, you can use the following shell scripts in this repo:
- install_ruby.sh - this will install ruby and bundler
- install_mongodb.sh - this will install and start mongodb
- deploy.sh - this will download and deploy [test application](https://github.com/express42/reddit)

### Startup scripts
To automate things a bit, you can use the following command when creating an instance:
```shell
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone europe-west1-b --metadata-from-file startup-script=startup-script.sh
```
Or you can use startup script from URL:
```shell
gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone europe-west1-b --metadata startup-script-url=https://storage.googleapis.com/mdsjip-infra-cloud-testapp/startup-script.sh
```

### Firewall rules
Firewall rule for allowing 9292 TCP can be created by this command:
```shell
gcloud compute firewall-rules create default-puma-server --description=default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
```

### Connecting to Test Application
```
testapp_IP=35.189.195.239
testapp_port=9292
```
