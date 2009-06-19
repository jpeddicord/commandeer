#!/usr/bin/make -f
# -*- indent-tabs-mode: 0; tab-width: 4; -*-

# there's probably a *lot* that could be done to make this more functional...
# but oh well, it works fine for its purpose.

PREFIX?=/usr/local

all:
	valac --pkg gtk+-2.0 --pkg posix commandeer.vala

install:
	install -D -m 755 commandeer $(PREFIX)/bin/commandeer

uninstall:
	rm -f $(PREFIX)/bin/commandeer

clean:
	$(RM) commandeer
