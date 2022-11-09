#!/bin/bash
apt update -y && apt upgrade -y && apt autoremove -y

# Prerequisites
sudo apt-get install -y build-essential
sudo mkdir -p /var/lib/jwtsecret
openssl rand -hex 32 | sudo tee /var/lib/jwtsecret/jwt.hex > /dev/null


# Golang (if needed)
cd ~
curl -LO https://go.dev/dl/go1.19.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
source $HOME/.profile
rm go1.19.linux-amd64.tar.gz


# Erigon

cd ~
git clone --recurse-submodules -j8 https://github.com/ledgerwatch/erigon.git
cd erigon
make erigon

#nohup ./build/bin/erigon --datadir=datagoerli --chain=goerli

cd ~
sudo cp -a erigon /usr/local/bin/erigon
rm -r erigon
sudo useradd --no-create-home --shell /bin/false erigon
sudo mkdir -p /var/lib/erigon
sudo chown -R erigon:erigon /var/lib/erigon


# Add Erigon service

echo "[Unit]
Description=Erigon Execution Client (Goerli)
After=network.target
Wants=network.target
[Service]
User=erigon
Group=erigon
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/erigon/build/bin/erigon \
  --datadir=/var/lib/erigondata \
  --chain=goerli \
  --rpc.gascap=50000000 \
  --http \
  --ws \
  --rpc.batch.concurrency=100 \
  --state.cache=2000000 \
  --http.addr="0.0.0.0" \
  --http.port=8545 \
  --http.api="eth,erigon,web3,net,debug,trace,txpool" \
  --authrpc.port=8551 \
  --private.api.addr="0.0.0.0:9595" \
  --http.corsdomain="*" \
  --torrent.download.rate 90m \
  --authrpc.jwtsecret=/var/lib/jwtsecret/jwt.hex \
  --metrics 
[Install]
WantedBy=default.target" >> /etc/systemd/system/erigon.service \


# Lighthouse Beacon

cd ~
curl -LO https://github.com/sigp/lighthouse/releases/download/v3.2.1/lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
tar xvf lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
sudo cp lighthouse /usr/local/bin
rm lighthouse-v3.2.1-x86_64-unknown-linux-gnu.tar.gz
rm lighthouse
sudo useradd --no-create-home --shell /bin/false lighthousebeacon
sudo mkdir -p /var/lib/lighthouse/beacon
sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon


# Add Lighthouse service

echo "[Unit]
Description=Lighthouse Consensus Client BN (Goerli)
Wants=network-online.target
After=network-online.target
[Service]
User=lighthousebeacon
Group=lighthousebeacon
Type=simple
Restart=always
RestartSec=5
ExecStart=/usr/local/bin/lighthouse bn \
  --network goerli \
  --datadir /var/lib/lighthouse \
  --http \
  --execution-endpoint http://localhost:8551 \
  --execution-jwt /var/lib/jwtsecret/jwt.hex \
  --metrics
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/lighthousebeacon.service \


# Install and launch services

sudo systemctl daemon-reload
sudo systemctl start erigon
sudo systemctl start lighthousebeacon
sudo systemctl enable erigon
sudo systemctl enable lighthousebeacon
