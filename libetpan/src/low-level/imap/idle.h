#ifndef MAILIMAP_IDLE_H

#define MAILIMAP_IDLE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "mailimap_types.h"

LIBETPAN_EXPORT
int mailimap_idle(mailimap * session);

LIBETPAN_EXPORT
int mailimap_idle_done(mailimap * session);

LIBETPAN_EXPORT
int mailimap_idle_get_fd(mailimap * session);

/* delay in seconds */
LIBETPAN_EXPORT
void mailimap_idle_set_delay(mailimap * session, long delay);

LIBETPAN_EXPORT
long mailimap_idle_get_done_delay(mailimap * session);

LIBETPAN_EXPORT
int mailimap_has_idle(mailimap * session);

#ifdef __cplusplus
}
#endif

#endif
