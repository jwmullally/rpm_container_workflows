FROM centos:7

RUN yum install -y make rpm-build && \
    install -o nobody -d /tmp/src/
COPY . /tmp/src/
USER nobody
RUN cd /tmp/src && make -f Makefile.srpm
USER root
RUN yum-builddep -y /tmp/src/rpmbuild/SRPMS/*.src.rpm
USER nobody
RUN rpmbuild --define "_topdir /tmp/src/rpmbuild/" \
        --rebuild /tmp/src/rpmbuild/SRPMS/*.src.rpm
USER root
RUN [ -z "$(rpm -qp --scripts /tmp/src/rpmbuild/RPMS/*/*.rpm)" ] && \
    yum install -y /tmp/src/rpmbuild/RPMS/*/*.rpm && \
    yum clean all -y

USER 1001
EXPOSE 8000
ENTRYPOINT ["/usr/bin/run-cgi-server.sh"]
