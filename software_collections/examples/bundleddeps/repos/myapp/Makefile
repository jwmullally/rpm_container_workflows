dependencies:
	rm -rf _dependencies
	python3 -m pip download --no-cache-dir --no-binary=:all: -d _dependencies -r requirements.txt
	# Fetch any local python package sdists here and put them into dependencies
	rm -rf dependencies
	mv _dependencies dependencies

venv: dependencies
	python3 -m virtualenv venv
	venv/bin/pip --isolated install --no-deps --no-compile --proxy localhost:0 --no-cache-dir dependencies/*

build: venv
	venv/bin/python setup.py build

test: venv
	#venv/bin/python setup.py test
	venv/bin/python manage.py test
	-venv/bin/pylint --persistent=n myapp *.py

install: build
	[ -d "$(BUILDROOT)" ] || (echo "BUILDROOT not a valid directory"; exit 1)
	rm -f venv/{pip-selfcheck.json,lib64}
	mkdir venv/lib64 && cd venv/lib64 && ln -s ../lib/python* .
	mkdir -p "$(BUILDROOT)$(DESTDIR)"
	tar -cO -C venv . | tar -C "$(BUILDROOT)$(DESTDIR)" -xf -
	venv/bin/python setup.py install --skip-build --no-compile --root "$(BUILDROOT)" --prefix="$(DESTDIR)"
	find "$(BUILDROOT)$(DESTDIR)/bin" -type f -a ! -type l -exec sed -i 's;$(shell pwd)/venv;$(DESTDIR);' {} \;

srpm: dependencies clean
	mkdir -p rpmbuild/SPECS
	cp myorg-myscl.spec rpmbuild/SPECS
	rpmbuild --define "_topdir `pwd`/rpmbuild" -bs rpmbuild/SPECS/myorg-myscl.spec
	
	tar -zcf rpmbuild/SOURCES/myapp.tar.gz \
		--exclude=.git --exclude=rpmbuild --exclude=dependencies \
		--transform='s;^./;myapp/;' .
	tar -cf rpmbuild/SOURCES/dependencies.tar dependencies
	cp myorg-myscl-myapp.spec rpmbuild/SPECS
	rpmbuild --define "_topdir `pwd`/rpmbuild" -bs rpmbuild/SPECS/myorg-myscl-myapp.spec

clean:
	rm -rf venv rpmbuild dist build *.egg-info .coverage
	find . -type d -name "__pycache__" -prune -exec rm -rf {} \;
	find . -type f -name "*.pyc" -delete
