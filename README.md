# RPM Container Workflows

Linux container/VM images are root file systems.

Distributions such as https://debian.org and https://redhat.com have built filesystems from 10,000s of packages for 20+ years using software packaged in DEB and RPM format.

This repository is a collection of different CI/CD approaches for building container filesystem images using RPMs.


For a much easier and hassle free way of turning source code into working images, checkout [S2I](https://github.com/openshift/source-to-image) or [Buildpacks](https://devcenter.heroku.com/articles/buildpacks).


## Examples

<img src="jenkins_mock/examples/multi_rpm/example.png" width="326" height="458">

Assembling an image from packages looks like this:

    Package source -> SRPMs -> RPMs -> Container Image

For simplicity and composability, each of these components is split into their own seperate git repositories.

General layout:

* 1 repo per RPM
* 1 repo per container (i.e. Dockerfile)
* 1 repo for container build orchestration definitions (Jenkinsfile, Kubernetes objects)


### Getting Started

To run these examples, you'll need a working Openshift cluster.

Sample run:

    $ oc cluster up
    $ cd docker_build
    $ ./project.sh create
    $ cd examples/multi_rpm
    $ ./example.sh create
    $ ./example.sh build


### Building RPMs inside Docker build

[docker_build/examples/multi_rpm](docker_build/examples/multi_rpm)

This example builds the RPMs inside the Docker image build phase. A simple Makefile is called from the Docker build which handles the repository fetching and SRPM assembly. These are then built serially with a simple rpmbuild. The installed build dependencies are then removed and the resulting RPMs are installed. 

One advantage of this method is its mechanical simplicity: only Docker and rpmbuild are needed. Another is that the build and runtime environment are the same container.

Using the Makefile and Dockerfile, the repos and container can be all be modified and built locally to test changes.

TODO: Currently the rpmbuild itself happens as root user (even though it should be confined within the Docker build). It should be easy to execute rpmbuild as non-root to lower attack surface.

[docker_build/examples/multi_rpm_submodules](docker_build/examples/multi_rpm_submodules)

This works like the above, except the RPMs repos are fetched with git submodules instead of from the Makefile.


### Building RPMs with mock

[jenkins_mock/examples/multi_rpm](jenkins_mock/examples/multi_rpm)

In this example, a Jenkinsfile defines a pipeline where SRPMs are built with [mock](https://github.com/rpm-software-management/mock/wiki) running on a Jenkins slave. A Makefile fetches the SRPMs and builds them using mockchain. The resulting RPMs are archived to Jenkins, then sent to a container build using "oc start-build --from-dir (RPMS+Dockerfile)" binary input build which copies them into the Docker build context. These are then installed during the Docker build.

One caveat of this approach is that currently mock must run in containers with CAP_SYS_ADMIN privilages, in order to set up chroot and mounts.

Using the same Makefile and Dockerfile, its possible to pull and modify the RPM repos locally, and build them with mock into a working container for testing. This can be done independantly of the build infrastructure. Like Docker, building under mock should be reproducible and portable, and not need any other tools to be installed, provided the local host mock has the same access to the YUM repositories as the mock configured on the Jenkins slave.

[jenkins_mock/examples/multi_rpm_imagesource](jenkins_mock/examples/multi_rpm_imagesource) 

This follows the same pipeline workflow, except the built RPMs are pushed to a seperate artifact image stream, which is then used as an input to the container build.


## TODO

* New package for python-demo_app uwsgi dependencies and init script, it will simplify the Docker files a bit

### More Examples

* mock SCM
* tito
* push artifacts to pulp
* koji
* (dist-git?.. not so useful for CI/CD)
* fedora modularity modules?

### Needed tools

#### mockchain without mock (rpmbuildchain?)

Replace the [rpmbuild section here](docker_build/examples/multi_rpm/repos/demo_container/Makefile) with tool or script.
