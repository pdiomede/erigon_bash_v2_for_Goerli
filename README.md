Erigon Archive + Lighthouse Beacon Install (for Goerli)
========================================================
### **Install Rust** ###

If you dont currently have rust installed, log out and back in after install.

`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`



### **Download install.sh** ###
`git clone https://github.com/pdiomede/erigon_bash_v2_for_Goerli`

`cd erigon_bash_v2_for_Goerli`

`chmod +x install.sh`


### **Run install.sh** ###
`./install.sh`

### **Check on the erigon service:** ###

`sudo journalctl -fu erigon`

### **Check on lighthouse beacon service** ###

`sudo journalctl -fu lighthousebeacon`

### **To make changes to erigon.service** ###

`sudo nano /etc/systemd/system/erigon.service`

### **To make changes to lighthousebeacon.service** ###

`sudo nano /etc/systemd/system/lighthousebeacon.service`

### **After making changes, dont forget to update** ###

`sudo systemctl daemon-reload`

`sudo systemctl restart erigon`

`sudo systemctl restart lighthousebeacon`


### **Allow Peers** ###

```ufw allow 30303```

```ufw allow 9000```

### **Allow RPC endpoint** ###
```ufw allow from 1.1.1.1 to any port 8545```








