
bin_PROGRAMS = commandeer
AM_CFLAGS = @GLIB_CFLAGS@ @GOBJECT_CFLAGS@ @GTK_CFLAGS@

commandeer_LDADD = @GLIB_LIBS@ @GOBJECT_LIBS@ @GTK_LIBS@
commandeer_VALASOURCES = Commandeer.vala

MAINTAINERCLEANFILES = $(commandeer_VALASOURCES:.vala=.c) \
	commandeer.stamp

BUILT_SOURCES = commandeer.stamp

commandeer_SOURCES = $(commandeer_VALASOURCES:.vala=.c)

EXTRA_DIST = $(commandeer_VALASOURCES) \
	commandeer.stamp

VALA_FLAGS = --pkg gtk+-2.0 \
	--pkg posix

commandeer.stamp: $(commandeer_VALASOURCES)
	$(VALAC) -C $(VALA_FLAGS) \
	$(commandeer_VALASOURCES)
	touch $@
