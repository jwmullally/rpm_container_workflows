# Inspired by http://www.projectatomic.io/docs/compose-your-own-tree/
FROM centos:7
RUN yum install -y make git rpm-build yum-utils createrepo_c && \
    curl -sS https://raw.githubusercontent.com/jwmullally/rpmbuild-chain/master/rpmbuild_chain/rpmbuild_chain.py -o /usr/local/bin/rpmbuild-chain && \
    chmod +x /usr/local/bin/rpmbuild-chain && \
    install -o nobody -d /srv/rpm-repo && \
    install -o nobody -d /tmp/build
WORKDIR /tmp/build
COPY . /tmp/build/
RUN runuser -u nobody -- make clean && \
    runuser -u nobody -- make srpms && \
    rpmbuild-chain --verbose --user nobody --repo-path /srv/rpm-repo \
        --srpms srpms --order-files build_order && \
    chown -R root.root /srv/rpm-repo && \
    rm -rf /tmp/build
WORKDIR /srv/rpm-repo
USER 1001
EXPOSE 8000
ENTRYPOINT ["python", "-m", "SimpleHTTPServer"]
