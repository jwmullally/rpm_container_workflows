GOGS_ENDPOINT=$(shell oc get route gogs --template={{.spec.host}})

all: image

repos:
	rm -rf _repos
	mkdir _repos
	cd _repos && git clone "http://developer:developer@${GOGS_ENDPOINT}/developer/python-hello_lib.git"
	cd _repos && git clone "http://developer:developer@${GOGS_ENDPOINT}/developer/python-demo_app.git"
	mv _repos repos

srpms: repos $(shell find repos -type f)
	rm -rf _srpms srpms
	mkdir _srpms
	cd repos/python-hello_lib && make -f Makefile.srpm && cp -v build/SRPMS/*.src.rpm ../../_srpms
	cd repos/python-demo_app && make -f Makefile.srpm && cp -v build/SRPMS/*.src.rpm ../../_srpms
	mv _srpms srpms

rpms: srpms
	rm -rf /tmp/mockchain _rpms rpms
	install -m 0777 -d /tmp/mockchain
	mockchain --root=epel-7-x86_64 -l /tmp/mockchain --tmp_prefix=mockchain --mock-option=--verbose \
		srpms/python-hello_lib-*.src.rpm \
		srpms/python-demo_app-*.src.rpm
	mkdir _rpms
	cp -rv /tmp/mockchain/results/epel-7-x86_64/* _rpms
	mv _rpms rpms

image: rpms Dockerfile
	cp -f Dockerfile rpms/
	sudo docker build --no-cache --tag demo-container rpms/
	touch image

run: stop
	sudo docker run --name demo-container demo-container

stop:
	-sudo docker stop demo-container
	-sudo docker rm demo-container

test:
	./test.sh "`sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' demo-container`:8000"

clean:
	rm -rf _repos _srpms _rpms srpms rpms image
