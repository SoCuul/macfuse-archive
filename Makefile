PROJECT = fuse-archive
PKG_CONFIG ?= pkg-config

FUSE_MAJOR_VERSION ?= 2

ifeq ($(FUSE_MAJOR_VERSION), 3)
CXXFLAGS += -DFUSE_USE_VERSION=30
else ifeq ($(FUSE_MAJOR_VERSION), 2)
CXXFLAGS += -DFUSE_USE_VERSION=26
endif


CXXFLAGS += -I/usr/local/include/fuse -I/opt/homebrew/opt/libarchive/include -I/opt/homebrew/opt/boost/include
LDFLAGS += -rpath /usr/local/lib -L/usr/local/lib -L/opt/homebrew/opt/boost/lib -lfuse-t -larchive
STD := c++20
CXXFLAGS += -std=$(STD) -Wall -Wextra -Wno-missing-field-initializers -Wno-sign-compare -Wno-unused-parameter -Wno-nullability-extension
CXXFLAGS += -D_FILE_OFFSET_BITS=64

ifeq ($(DEBUG), 1)
CXXFLAGS += -O0 -g
else
CXXFLAGS += -O2 -DNDEBUG
endif

PREFIX = $(DESTDIR)/usr
BINDIR = $(PREFIX)/bin
MAN = $(PROJECT).1
MANDIR = $(PREFIX)/share/man/man1
INSTALL = install


all: out/$(PROJECT)

check: out/$(PROJECT) test/data/big.zip test/data/collisions.zip
	python3 test/test.py

clean:
	rm -rf out

doc: $(MAN)
	man -l $(MAN)

$(MAN): README.md
	pandoc $< -s -t man -o $@

install: out/$(PROJECT)
	$(INSTALL) -D "out/$(PROJECT)" "$(BINDIR)/$(PROJECT)"
	$(INSTALL) -D -m 644 $(MAN) "$(MANDIR)/$(MAN)"

install-strip: out/$(PROJECT)
	$(INSTALL) -D -s "out/$(PROJECT)" "$(BINDIR)/$(PROJECT)"
	$(INSTALL) -D -m 644 $(MAN) "$(MANDIR)/$(MAN)"

uninstall:
	rm "$(BINDIR)/$(PROJECT)" "$(MANDIR)/$(MAN)"

out/$(PROJECT): $(PROJECT).cc
	mkdir -p out
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< $(LDFLAGS) -o $@

test/data/big.zip: test/make_big_zip.py
	python3 test/make_big_zip.py

test/data/collisions.zip: test/make_collisions.py
	python3 test/make_collisions.py

.PHONY: all check clean doc install uninstall
