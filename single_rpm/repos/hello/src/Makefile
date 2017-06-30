all: hello

hello: hello.c
	gcc -o hello hello.c -Wall

test: all
	./test.sh ./hello

clean:
	rm -f hello

install: all
	install -m 0755 -d $(DESTDIR)/usr/bin/
	install -m 0755 hello $(DESTDIR)/usr/bin/
