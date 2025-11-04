#apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common &&\
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&\
#apt-key fingerprint 0EBFCD88
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&\
#apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

#docker run -d --name prom-node-exporter \
#    -v /proc:/host/proc \
#    -v /sys:/host/sys \
#    -v /:/host \
#    --net=host \
#    --restart unless-stopped \
#    rancher/prom-node-exporter:v0.17.0 \
#    --web.listen-address=172.16.0.16:9796 --path.procfs=/host/proc --path.sysfs=/host/sys --path.rootfs=/host --collector.arp \
#    --collector.bcache --collector.bonding --no-collector.buddyinfo --collector.conntrack --collector.cpu --collector.diskstats \
#    --no-collector.drbd --collector.edac --collector.entropy --collector.filefd --collector.filesystem --collector.hwmon \
#    --collector.infiniband --no-collector.interrupts --collector.ipvs --no-collector.ksmd --collector.loadavg --no-collector.logind \
#    --collector.mdadm --collector.meminfo --no-collector.meminfo_numa --no-collector.mountstats --collector.netdev --collector.netstat \
#    --no-collector.nfs --no-collector.nfsd --no-collector.ntp --no-collector.processes --no-collector.qdisc --no-collector.runit --collector.sockstat \
#    --collector.stat --no-collector.supervisord --no-collector.systemd --no-collector.tcpstat --collector.textfile --collector.time \
#    --collector.timex --collector.uname --collector.vmstat --no-collector.wifi --collector.xfs --collector.zfs

#docker run -d --name prom-postgres-exporter \
#  --restart unless-stopped \
#  --net=host \
#  -e DATA_SOURCE_NAME="postgresql://postgres:53986e6f1b1d35e678e202c6ec42a96d@localhost:5432/postgres?sslmode=disable" \
#  quay.io/prometheuscommunity/postgres-exporter@sha256:38606faa38c54787525fb0ff2fd6b41b4cfb75d455c1df294927c5f611699b17 \
#  --web.listen-address=172.16.0.16:9797
