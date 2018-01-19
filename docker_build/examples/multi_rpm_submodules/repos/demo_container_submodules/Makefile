all: image

srpms: $(shell find repos -type f)
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

install-rpms: srpms
	rm -rf _rpms rpms
	mkdir _rpms
	for pkg in \
		"python-hello_lib"\
		"python-demo_app"\
	; do \
		rpm --define "_topdir `pwd`/_rpms/$$pkg/" \
			-i srpms/$$pkg/*.src.rpm && \
		rpmbuild --define "_topdir `pwd`/_rpms/$$pkg/" \
			-bs _rpms/$$pkg/SPECS/*.spec && \
		yum-builddep -y _rpms/$$pkg/SRPMS/*.src.rpm && \
		rpmbuild --define "_topdir `pwd`/_rpms/$$pkg/" \
			-bb _rpms/$$pkg/SPECS/*.spec && \
		rpm -iv _rpms/$$pkg/RPMS/*/*.rpm; \
	done
	mv _rpms rpms

image: Dockerfile srpms
	sudo docker build --no-cache --tag demo-container .
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
