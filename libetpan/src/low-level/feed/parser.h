#ifndef PARSER_H

#define PARSER_H

#include "newsfeed_private.h"

void newsfeed_parser_set_expat_handlers(struct newsfeed_parser_context * ctx);
size_t newsfeed_writefunc(void * ptr, size_t size, size_t nmemb, void * stream);
const char * newsfeed_parser_get_attribute_value(const char ** attr,
    const char * name);

#endif /* __PARSER_H */
