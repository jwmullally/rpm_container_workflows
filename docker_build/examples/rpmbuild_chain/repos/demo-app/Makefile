#GOGS_ENDPOINT=$(shell oc get route gogs --template={{.spec.host}})
GOGS_ENDPOINT="gogs.rpm-docker-build.svc.cluster.local:3000"

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

clean:
	rm -rf _repos _srpms srpms
