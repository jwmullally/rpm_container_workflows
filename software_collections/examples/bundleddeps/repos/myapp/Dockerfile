FROM centos:7

RUN install -o nobody -d /tmp/src/
WORKDIR /tmp/src
COPY . /tmp/src/
RUN yum install -y centos-release-scl && \
    yum -v repolist enabled && \
    (yum history | grep -o '^\s*[0-9]*' | head -n 1 | tee /tmp/YUM_CHECKPOINT) && \
    yum install -y make rpm-build scl-utils-build && \
    runuser -u nobody -- make srpm && \
    yum-builddep -y rpmbuild/SRPMS/*.src.rpm && \
    runuser -u nobody -- rpmbuild --define "_topdir $(pwd)/rpmbuild/" \
        --rebuild rpmbuild/SRPMS/*.src.rpm && \
    [ -z "$(rpm -qp --scripts rpmbuild/RPMS/*/*.rpm)" ] && \
    yum history -y rollback force "$(cat /tmp/YUM_CHECKPOINT)" && \
    yum install -y rpmbuild/RPMS/*/*.rpm && \
    rpm -V myorg-myscl-myapp && \
    yum clean all -y
USER 1001
EXPOSE 8000
WORKDIR /var/opt/myorg/myorg-myscl/db/
ENTRYPOINT ["/usr/bin/scl", "enable", "myorg-myscl", "myapp.sh"]
