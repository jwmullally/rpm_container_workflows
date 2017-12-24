## Quickly patching an RPM installed in a container

The advantage of using patch files is that they make changes for the package easy to see, discuss and reuse.

An alternative to copying in a modified SRPM into the Docker build is to instead copy in the spec and source directory (rpmbuild/BUILD/package-ver) and use "rpmbuild --build-in-place"

### Preparation

Create a new Dockerfile that will build and layer our modified package on top of the image we are troubleshooting:

    cat > Dockerfile <<EOF
    FROM 172.30.1.1:5000/myproject/xrdp-container:latest
    USER root
    RUN dnf -y install rpm-build && \
        dnf -y builddep xrdp
    COPY rpmbuild/SRPMS/* /tmp/srpm/
    RUN dnf -y builddep /tmp/srpm/*
    RUN rpmbuild -D "%_topdir /tmp/rpmbuild" --rebuild /tmp/srpm/*
    RUN dnf -y install /tmp/rpmbuild/RPMS/*/*.rpm
    USER 1001
    EOF

Fetch and extract the original SRPM:

    wget https://kojipkgs.fedoraproject.org/packages/xrdp/0.9.4/2.fc27/src/xrdp-0.9.4-2.fc27.src.rpm
    rpm -D "%_topdir $(pwd)/rpmbuild" -ivh xrdp-0.9.4-2.fc27.src.rpm
    rpmbuild -D "%_topdir $(pwd)/rpmbuild" -bp --nodeps rpmbuild/SPECS/xrdp.spec

Add our custom patch to the spec:

    cd rpmbuild/SPECS
    patch -p0 <<EOF
    --- xrdp.spec.old
    +++ xrdp.spec
    @@ -10,1 +10,1 @@
    -Release:   2%{?dist}
    +Release:   2%{?dist}.debug
    @@ -26,2 +26,3 @@
     Patch5:    xrdp-0.9.4-CVE-2017-16927.patch
    +Patch6:    debug.patch

    EOF

Save a copy of the original source for patch generation:

    cd ../BUILD
    mv xrdp-0.9.4 xrdp-0.9.4.old
    cp -rv xrdp-0.9.4.old xrdp-0.9.4.debug

### Rerun these steps as many times as needed

Make changes to the sources:

    vi xrdp-0.9.4.debug/sesman/env.c

Generate the patch and rebuild the SRPM: (Depending on the patch level used in %prep you make have to change from where you run diff)

    diff -Naur xrdp-0.9.4.old xrdp-0.9.4.debug | tee ../SOURCES/debug.patch
    rpmbuild -D "%_topdir $(pwd)/.." -bs ../SPECS/xrdp.spec
    ls -la ../SRPMS

Build the debug Docker image:

    sudo docker build --tag xrdp-app-debug .

For OpenShift, this could be:

    oc start-build xrdp-app-debug --from-dir . --follow=true

