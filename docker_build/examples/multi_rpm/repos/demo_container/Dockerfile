FROM centos:7
COPY . /tmp/build/
RUN sed -i 's/enabled\s*=\s*1/enabled = 0/' /etc/yum/pluginconf.d/fastestmirror.conf && \
    yum install -y epel-release && \
    yum -v repolist enabled && \
    (yum history | grep -o '^\s*[0-9]*' | head -n 1 | tee /tmp/YUM_CHECKPOINT) && \
    yum install -y make rpm-build createrepo_c git && \
# For faster layered builds, move the COPY to here
#COPY . /tmp/build/
    cd /tmp/build && \
    make rpms && \
    # Would be nice to merge the rollback and install transactions to avoid
    # re-downloading runtime dependencies that were also fetched during build
    yum history && \
    yum history -y rollback force "$(cat /tmp/YUM_CHECKPOINT)" && \
    yum install -y \
        uwsgi \
        uwsgi-plugin-python \
        python2-hello_lib \
        python2-demo_app \
    rpm -q \
        uwsgi \
        uwsgi-plugin-python \
        python2-hello_lib \
        python2-demo_app && \
    yum clean all -y && \
    rm -rf /tmp/build
USER 1001
EXPOSE 8000 9191
ENTRYPOINT ["/usr/sbin/uwsgi", "--plugin", "python,http", "--http", ":8000", "--module", "demo_app:app", "--master", "--processes", "4", "--threads", "2", "--stats", ":9191"]
