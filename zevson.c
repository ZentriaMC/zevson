#ifdef __APPLE__
// conflicting declarations of strlcat and strlcpy in libspl
#define HAVE_STRLCAT
#define HAVE_STRLCPY
#endif

#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <time.h>
#include <libzfs.h>

#ifndef ZEVENT_NONE
#define ZEVENT_NONE 0x0
#endif

static void logmsg(const char *fmt, ...) {
	time_t now = time(NULL);
	char buf[21];
	strftime(buf, (sizeof buf), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));

	va_list args;
	fprintf(stderr, "[%s]: ", buf);
	va_start(args, fmt);
	vfprintf(stderr, fmt, args);
	va_end(args);
}

static int process_event(libzfs_handle_t *h, int zfs_fd) {
	nvlist_t *nvl;
	int d, r;

	if ((r = zpool_events_next(h, &nvl, &d, ZEVENT_NONE, zfs_fd)) != 0 || !nvl) {
		return errno;
	}

	if (d) {
		printf("{\"dropped_events\": %d}\n", d);
		logmsg("dropped %d event(s)\n", d);
	}

	nvlist_print_json(stdout, nvl);
	printf("\n");

	nvlist_free(nvl);
	return 0;
}

int main(int argc, char **argv) {
	int r, zfs_fd;
	libzfs_handle_t *handle;
	if ((handle = libzfs_init()) == NULL) {
		logmsg("libzfs_init(): %s\n", strerror(errno));
		return 1;
	}

	if ((zfs_fd = open(ZFS_DEV, O_RDWR)) < 0) {
		logmsg("open %s: %s\n", ZFS_DEV, strerror(errno));
		return 1;
	}

	setvbuf(stdout, NULL, _IONBF, 0);

	while ((r = process_event(handle, zfs_fd)) == 0) {
		;
	}
	if (r != 0) {
		logmsg("failed to handle event: %s\n", strerror(errno));
	}

	close(zfs_fd);
	libzfs_fini(handle);
	return 0;
}
