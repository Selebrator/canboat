#
# Makefile for all UNIX style platforms including Cygwin
#
# (C) 2009-2017, Kees Verruijt, Harlingen, The Netherlands
#
# $Id:$
#

# s. https://www.gnu.org/prep/standards/html_node/Directory-Variables.html#Directory-Variables
DESTDIR ?= ""
PREFIX ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
BINDIR=$(EXEC_PREFIX)/bin
SYSCONFDIR= /etc
DATAROOTDIR ?= $(PREFIX)/share
MANDIR= $(DATAROOTDIR)/man

PLATFORM=$(shell uname | tr '[A-Z]' '[a-z]')-$(shell uname -m)
OS=$(shell uname -o 2>&1)
SUBDIRS= actisense-serial analyzer n2kd nmea0183 ip group-function candump2analyzer socketcan-writer ikonvert-serial

BUILDDIR ?= ./rel/$(PLATFORM)

MKDIR = mkdir -p
export HELP2MAN=$(shell command -v help2man 2> /dev/null)

CONFDIR=$(SYSCONFDIR)/default

ROOT_UID=0
ROOT_GID=0
ROOT_MOD=0644

all:	bin compile
	@echo "The binaries are now built and are in $(BUILDDIR)"
	@echo "Use 'make generated' to recreate generated XML, JSON and DBC files."

compile: bin
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir; done

tests:  compile
	$(MAKE) -C analyzer tests
	$(MAKE) -C n2kd tests

generated: tests
	$(MAKE) -C analyzer generated
	$(MAKE) -C dbc-exporter

bin:	$(BUILDDIR)

$(BUILDDIR):
	$(MKDIR) -p $(BUILDDIR)

man1: man/man1

man/man1:
	$(MKDIR) man/man1

clean:
	for dir in $(SUBDIRS); do $(MAKE) -C $$dir clean; done
	$(MAKE) -C dbc-exporter clean
	-rm -R -f man $(BUILDDIR)

install: $(BUILDDIR)/analyzer $(DESTDIR)$(BINDIR) $(DESTDIR)$(CONFDIR) $(DESTDIR)$(MANDIR)/man1
	for i in $(BUILDDIR)/* util/* */*_monitor; do if [ -x $$i ]; then f=`basename $$i`; echo $$f; rm -f $(DESTDIR)$(BINDIR)/$$f; cp $$i $(DESTDIR)$(BINDIR); fi; done
	for i in config/*; do install -m $(ROOT_MOD) $$i $(DESTDIR)$(CONFDIR); done
ifeq ($(notdir $(HELP2MAN)),help2man)
	for i in man/man1/*; do echo $$i; install -m $(ROOT_MOD) $$i $(DESTDIR)$(MANDIR)/man1; done
endif

format:
	for file in */*.c */*.h; do clang-format -i $$file; done

.PHONY : $(SUBDIRS) clean install zip bin format man1 tests generated compile

$(DESTDIR)$(BINDIR):
	$(MKDIR) $(DESTDIR)$(BINDIR)

$(DESTDIR)$(CONFDIR):
	$(MKDIR) $(DESTDIR)$(CONFDIR)

$(DESTDIR)$(MANDIR)/man1:
	$(MKDIR) $(DESTDIR)$(MANDIR)/man1
