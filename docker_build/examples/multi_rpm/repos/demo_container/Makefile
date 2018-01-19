#GOGS_ENDPOINT=$(shell oc get route gogs --template={{.spec.host}})
GOGS_ENDPOINT="gogs.rpm-docker-build.svc.cluster.local:3000"

all: image

repos:
	rm -rf _repos
	mkdir _repos
	cd _repos && git clone "http://${GOGS_ENDPOINT}/developer/python-hello_lib.git"
	cd _repos && git clone "http://${GOGS_ENDPOINT}/developer/python-demo_app.git"
	mv _repos repos

srpms: repos $(shell find repos -type f)
	rm -rf _srpms srpms
	mkdir _srpms
	
	cd repos/python-hello_lib && \
		make -f Makefile.srpm && \
		mv -v rpmbuild/SRPMS ../../_srpms/python-hello_lib && \
		make -f Makefile.srpm clean
	
	cd repos/python-demo_app && \
		make -f Makefile.srpm && \
		mv -v rpmbuild/SRPMS ../../_srpms/python-demo_app && \
		make -f Makefile.srpm clean

	mv _srpms srpms

rpms: srpms
	# Build RPMs like mockchain. This could be scripted...
	rm -rf yum_repo
	mkdir yum_repo
	createrepo_c -v yum_repo
	echo -e "[demo_container]\nname=demo_container\nbaseurl=file://$(shell pwd)/yum_repo\nenabled=1\ngpgcheck=0\nmetadata_expire=0" > /etc/yum.repos.d/demo_container.repo
	for pkg in \
		"python-hello_lib"\
		"python-demo_app"\
	; do \
		rpm --define "_topdir `pwd`/yum_repo/$$pkg/" \
			-i srpms/$$pkg/*.src.rpm && \
		rpmbuild --define "_topdir `pwd`/yum_repo/$$pkg/" \
			-bs yum_repo/$$pkg/SPECS/*.spec && \
		yum-builddep -y yum_repo/$$pkg/SRPMS/*.src.rpm && \
		rpmbuild --define "_topdir `pwd`/yum_repo/$$pkg/" \
			-bb yum_repo/$$pkg/SPECS/*.spec && \
		createrepo_c --update yum_repo && \
		yum repolist --disablerepo=* --enablerepo=demo_container ; \
	done
	touch rpms

image: Dockerfile srpms
	sudo docker build --tag demo-container .
	touch image

run: stop
	sudo docker run --name demo-container demo-container

stop:
	-sudo docker stop demo-container
	-sudo docker rm demo-container

test:
	./test.sh "`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' demo-container`:8000"

clean:
	rm -rf _repos _srpms srpms rpms yum_repo image
