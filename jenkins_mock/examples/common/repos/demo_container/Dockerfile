FROM centos:7
COPY yum_repo /tmp/yum_repo
RUN sed -i 's/enabled\s*=\s*1/enabled = 0/' /etc/yum/pluginconf.d/fastestmirror.conf && \
    yum-config-manager --nogpgcheck --add-repo=file:///tmp/yum_repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/tmp_yum_repo.repo && \
    yum install -y epel-release && \
    yum -v repolist enabled && \
    yum install -y \
        uwsgi \
        uwsgi-plugin-python \
        python2-hello_lib \
        python2-demo_app && \
    yum clean all -y && \
    rpm -q \
        uwsgi \
        uwsgi-plugin-python \
        python2-hello_lib \
        python2-demo_app
USER 1001
EXPOSE 8000 9191
ENTRYPOINT ["/usr/sbin/uwsgi", "--plugin", "python,http", "--http", ":8000", "--module", "demo_app:app", "--master", "--processes", "4", "--threads", "2", "--stats", ":9191"]
