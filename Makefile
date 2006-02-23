
TARGETS = grubby
OBJECTS = grubby.o

include ../Makefile.inc

CFLAGS := $(CFLAGS) -iquote../nash/ $(RPM_OPT_FLAGS)
LDFLAGS := $(CFLAGS) -Wl,--wrap,open,--wrap,fopen,--wrap,opendir

LIBS = -lblkid -luuid -lpopt -ldevmapper -lselinux -lsepol

test: all
	@./test.sh

install: all
	mkdir -p $(BUILDROOT)/sbin
	mkdir -p $(BUILDROOT)/$(mandir)/man8
	install -m 755 new-kernel-pkg $(BUILDROOT)/sbin
	if [ -f grubby ]; then \
		install -m 755 -s grubby $(BUILDROOT)/sbin ; \
		install -m 644 grubby.8 $(BUILDROOT)/$(mandir)/man8 ; \
	fi

NASH_OBJECTS := block.o lib.o
$(NASH_OBJECTS): %.o : ../nash/%.c
	$(CC) $(CFLAGS) -iquote../nash/ -c -o $@ $<

grubby:: $(NASH_OBJECTS) $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ -Wl,-Bstatic $(LIBS) -Wl,-Bdynamic

