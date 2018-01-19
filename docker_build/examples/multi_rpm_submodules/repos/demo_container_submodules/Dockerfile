FROM centos:7
COPY . /tmp/build/
RUN sed -i 's/enabled\s*=\s*1/enabled = 0/' /etc/yum/pluginconf.d/fastestmirror.conf && \
    yum install -y epel-release make rpm-build git && \
    yum -v repolist enabled && \
    cd /tmp/build && \
    make install-rpms && \
    make clean && \
    yum install -y \
        uwsgi \
        uwsgi-plugin-python && \
    yum clean all -y && \
    rpm -q \
        uwsgi \
        uwsgi-plugin-python \
        python2-hello_lib \
        python2-demo_app
USER 1001
EXPOSE 8000 9191
ENTRYPOINT ["/usr/sbin/uwsgi", "--plugin", "python,http", "--http", ":8000", "--module", "demo_app:app", "--master", "--processes", "4", "--threads", "2", "--stats", ":9191"]
