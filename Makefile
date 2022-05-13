ZFS_INCLUDES	?= $(shell pkg-config --cflags libzfs)
ZFS_LIBS	?= $(shell pkg-config --libs libzfs)

CFLAGS	:= -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE $(ZFS_INCLUDES)
LDFLAGS	:= $(ZFS_LIBS)
CC	:= cc

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

zevson: zevson.o
	$(CC) $(LDFLAGS) -o $@ $<

clean:
	rm -rf zevson *.o
