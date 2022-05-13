CFLAGS	?= -I/usr/local/zfs/include/libspl -I/usr/local/zfs/include/libzfs
LDFLAGS	?= -L/usr/local/zfs/lib -lzfs -lnvpair
CC	?= cc

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

zevson: zevson.o
	$(CC) $(LDFLAGS) -o $@ $<

clean:
	rm -rf zevson *.o
