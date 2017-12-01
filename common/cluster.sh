#!/bin/sh -ex

# Some helper functions for starting a test Openshift cluster

#EXTRA_OPTIONS=" --logging --metrics"
CLUSTER_UP="oc cluster up --host-data-dir=/var/lib/origin/openshift.local.etcd --public-hostname=master.cluster.test --routing-suffix=apps.cluster.test $EXTRA_OPTIONS"
CALLER=`logname`

function setupnetwork {
    # https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md#getting-started"
    sed -i "s/^#INSECURE_REGISTRY=.*$/INSECURE_REGISTRY='--insecure-registry 172.30.0.0\/16'/" /etc/sysconfig/docker

    firewall-cmd --permanent --new-zone dockerc
    firewall-cmd --permanent --zone dockerc --change-interface docker0
    firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
    firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
    firewall-cmd --permanent --zone dockerc --add-port 53/udp
    firewall-cmd --permanent --zone dockerc --add-port 8053/udp

    # Allow internal nodes to access services as presented on the public router
    # For situations where internal and external processes need to use
    # the same URLs (e.g. working with gog's repos)
    firewall-cmd --permanent --zone dockerc --add-port 80/tcp
    firewall-cmd --permanent --zone dockerc --add-port 443/tcp
    firewall-cmd --reload

    # Debug firewall issues with:
    #  firewall-cmd --set-log-denied=all
    #  journalctl -k -f

    # Use *.cluster.test for the service addresses instead of external xip.io
    # dnsmasq forwards local queries and queries from pods to OpenShift SkyDNS
    cat > /etc/docker/daemon.json <<EOF
{
    "dns": [
        "172.17.0.1"
    ]
}
EOF

    cat > /etc/NetworkManager/conf.d/enable-dnsmasq.conf <<EOF
[main]
dns=dnsmasq
EOF

    cat > /etc/NetworkManager/dnsmasq.d/openshift-local.conf <<EOF
host-record=master.cluster.test,172.17.0.1
address=/apps.cluster.test/172.17.0.1
server=/cluster.local/127.0.0.1#8053
server=/30.172.in-addr.arpa/127.0.0.1#8053
interface=docker0
#log-queries
EOF

    # Optional: for setting for nice looking DNS addresses (e.g. *.example.com),
    #           use local dnsmasq server. See:
    # https://developers.redhat.com/blog/2015/11/19/dns-your-openshift-v3-cluster/

    systemctl daemon-reload
    systemctl restart docker
    systemctl restart NetworkManager
}

function new {
    clean
    $CLUSTER_UP
    cp -rn /root/.kube /home/$CALLER/
    chown -R $CALLER.$CALLER /home/$CALLER/.kube
}

function up {
    $CLUSTER_UP --use-existing-config
}

function down {
    oc cluster down
    # for some reason there are still kubernetes mounts still active...
    for mnt in `mount | grep "/var/lib/origin" | cut -d" " -f3`; do
        umount "$mnt"
    done
}

function clean {
    down
    rm -rf /var/lib/origin
    rm -rf /root/.kube
    rm -rf /home/$CALLER/.kube
}

function admin {
    oc login -u system:admin
    oc adm policy add-cluster-role-to-user cluster-admin developer
    oc login -u developer
}

case $1 in
    new)
        new
        ;;
    up)
        up
        ;;
    down)
        down
        ;;
    clean)
        clean
        ;;
    admin)
        admin
        ;;
    setupnetwork)
        setupnetwork
        ;;
    *)
        echo "$0 new|up|down|clean|admin|setupnetwork"
        ;;
esac
