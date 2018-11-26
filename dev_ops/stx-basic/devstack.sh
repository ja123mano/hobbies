#!/bin/bash
mkdir -p /opt/stack
sudo useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack bash << EOF
cd /opt/stack
export http_proxy="http://proxy-chain.intel.com:911"
export https_proxy="http://proxy-chain.intel.com:911"
echo "disable autoupdate"
sudo swupd autoupdate --disable
echo "create folders under /etc"
sudo mkdir -p /etc/libvirt
sudo mkdir -p /etc/bash_completion.d
sudo mkdir -p /etc/tgt/
echo "create symblinks under /etc"
sudo ln -s /usr/share/defaults/etc/hosts /etc/hosts
sudo ln -s /usr/lib/systemd/journald.conf.d/clear.conf /etc/systemd/journald.conf
sudo ln -s /usr/share/defaults/sudo/sudoers.d /etc/sudoers.d
echo "start needed services"
sudo systemctl start rabbitmq-server.service
sudo cp /var/lib/rabbitmq/.erlang.cookie $HOME/.erlang.cookie
sudo cp /var/lib/rabbitmq/.erlang.cookie /root/.erlang.cookie

rm -rf devstack/
git clone --depth=1 https://github.com/starlingx-staging/devstack.git -b stx/pike
curl -O -L https://patch-diff.githubusercontent.com/raw/starlingx-staging/devstack/pull/10.patch
curl -O -L https://patch-diff.githubusercontent.com/raw/starlingx-staging/devstack/pull/24.patch

cd devstack/
git apply ../10.patch
git apply ../24.patch
mv  local.conf.example_vanilla local.conf
echo "HOST_IP=127.0.0.1" >> local.conf
echo "GIT_BASE=https://git.openstack.org" >> local.conf
./stack.sh

EOF
