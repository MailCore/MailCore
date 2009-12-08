#ifndef NEWSFEED_ITEM_ENCLOSURE_H

#define NEWSFEED_ITEM_ENCLOSURE_H

#include <libetpan/newsfeed_types.h>

struct newsfeed_item_enclosure * newsfeed_item_enclosure_new(void);
void newsfeed_item_enclosure_free(struct newsfeed_item_enclosure * enclosure);

char * newsfeed_item_enclosure_get_url(struct newsfeed_item_enclosure * enclosure);
int newsfeed_item_enclosure_set_url(struct newsfeed_item_enclosure * enclosure,
    const char * url);

char * newsfeed_item_enclosure_get_type(struct newsfeed_item_enclosure * enclosure);
int newsfeed_item_enclosure_set_type(struct newsfeed_item_enclosure * enclosure,
    const char * type);

size_t newsfeed_item_enclosure_get_size(struct newsfeed_item_enclosure * enclosure);
void newsfeed_item_enclosure_set_size(struct newsfeed_item_enclosure * enclosure,
    size_t size);

#endif
