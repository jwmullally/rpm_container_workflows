FROM centos:7
RUN yum install -y make git rpm-build yum-utils createrepo_c epel-release && \
    yum install -y python-pip && \
    pip install rpmbuild-chain && \
    install -o nobody -d /tmp/build
WORKDIR /tmp/build
COPY . /tmp/build/
RUN runuser -u nobody -- make clean && \
    runuser -u nobody -- make srpms && \
    rpmbuild-chain --verbose --user nobody --keep-repo-config \
        --srpms srpms --order-files build_order && \
    yum -v repolist enabled && \
    PKGS="python2-demo_app uwsgi uwsgi-plugin-python" && \
    yum install -y $PKGS && \
    rpm -q $PKGS && \
    yum clean all -y
USER 1001
EXPOSE 8000 9191
ENTRYPOINT ["/usr/sbin/uwsgi", "--plugin", "python,http", "--http", ":8000", "--module", "demo_app:app", "--master", "--processes", "4", "--threads", "2", "--stats", ":9191"]
