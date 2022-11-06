# This is to clean the Erigon and Lighthouse setup in case you want to start again

rm -r /var/lib/jwtsecret

rm -r /usr/local/bin/erigon
rm -r /var/lib/erigon
rm /etc/systemd/system/erigon.service

rm -r /var/lib/lighthouse
rm -r /usr/local/bin/lighthouse
rm /etc/systemd/system/lighthousebeacon.service 
