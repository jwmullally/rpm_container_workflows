FROM centos:7
RUN yum install -y epel-release && \
    echo -e "[rpm-repo]\nname=rpm-repo\nbaseurl=http://rpm-repo:8000/\nenabled=1\ngpgcheck=0\nmetadata_expire=0\n" > /etc/yum.repos.d/rpm-repo.repo && \
    yum -v repolist enabled && \
    PKGS="python2-demo_app uwsgi uwsgi-plugin-python" && \
    yum install -y $PKGS && \
    rpm -q $PKGS && \
    yum clean all -y
USER 1001
EXPOSE 8000 9191
ENTRYPOINT ["/usr/sbin/uwsgi", "--plugin", "python,http", "--http", ":8000", "--module", "demo_app:app", "--master", "--processes", "4", "--threads", "2", "--stats", ":9191"]
