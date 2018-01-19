all: hello

hello: hello.c
	gcc -Wall -g -o hello hello.c

test: all
	./test.sh ./hello

clean:
	rm -f hello

install: all
	install -m 0755 -d $(DESTDIR)/usr/bin/
	install -m 0755 run-cgi-server.sh $(DESTDIR)/usr/bin/
	install -m 0755 -d $(DESTDIR)/var/www/cgi-bin
	install -m 0644 index.html $(DESTDIR)/var/www/
	install -m 0755 hello $(DESTDIR)/var/www/cgi-bin/
