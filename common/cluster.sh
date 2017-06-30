#!/bin/sh -ex

# Some helper functions for starting a test Openshift cluster

CLUSTER_UP='oc cluster up --host-data-dir=/var/lib/origin/openshift.local.etcd --public-hostname=172.17.0.1 --routing-suffix=172.17.0.1.nip.io'
#CLUSTER_UP='oc cluster up --host-data-dir=/var/lib/origin/openshift.local.etcd --public-hostname=172.17.0.1 --routing-suffix=172.17.0.1.nip.io --logging --metrics'
CALLER=`logname`

function common_start {
    #systemctl stop libvirtd
    #systemctl kill libvirtd     # libvirtd runs nameserver on port 53
    systemctl start docker
}

function prechecks {
    RUNNING_NAMESERVERS=`ss -Hnlp '( sport = :53 )'`
    if [ "$RUNNING_NAMESERVERS" ]; then
        echo "Conflicting nameservers still running:"
        echo "$RUNNING_NAMESERVERS"
        exit 1
    fi

    # Tested on Fedora 25

    # https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md#getting-started
    # To let the internal services hit the public facing router addresses,
    # add these:
    #firewall-cmd --permanent --zone dockerc --add-port 80/tcp
    #firewall-cmd --permanent --zone dockerc --add-port 443/tcp
    #firewall-cmd --reload

    # Debug firewall issues with:
    #firewall-cmd --set-log-denied=all
    #journalctl -k -f

    # Optional: for nice looking DNS addresses (e.g. *.example.com),
    #           use local dnsmasq server. See:
    # https://developers.redhat.com/blog/2015/11/19/dns-your-openshift-v3-cluster/

}

function new {
    common_start
    clean
    prechecks
    $CLUSTER_UP
    cp -rn /root/.kube /home/$CALLER/
    chown -R $CALLER.$CALLER /home/$CALLER/.kube
}

function up {
    common_start
    prechecks
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
    oc adm policy add-cluster-role-to-user cluster-admin developer
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
    --help)
        echo "$0 new|up|down|clean|admin"
        ;;
esac
