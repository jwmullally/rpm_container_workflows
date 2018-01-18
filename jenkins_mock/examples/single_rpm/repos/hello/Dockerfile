FROM centos:7
COPY *.rpm /tmp/rpms/
RUN yum install -y /tmp/rpms/*.rpm && \
    yum clean all -y
USER 1001
EXPOSE 8000
ENTRYPOINT ["/usr/bin/run-cgi-server.sh"]
