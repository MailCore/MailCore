#ifndef NEWSFEED_TYPES_H

#define NEWSFEED_TYPES_H

#include <libetpan/carray.h>
#include <sys/types.h>

enum {
  NEWSFEED_NO_ERROR = 0,
  NEWSFEED_ERROR_CANCELLED,
  NEWSFEED_ERROR_INTERNAL,
  NEWSFEED_ERROR_BADURL,
  NEWSFEED_ERROR_RESOLVE_PROXY,
  NEWSFEED_ERROR_RESOLVE_HOST,
  NEWSFEED_ERROR_CONNECT,
  NEWSFEED_ERROR_STREAM,
  NEWSFEED_ERROR_PROTOCOL,
  NEWSFEED_ERROR_PARSE,
  NEWSFEED_ERROR_ACCESS,
  NEWSFEED_ERROR_AUTHENTICATION,
  NEWSFEED_ERROR_FTP,
  NEWSFEED_ERROR_PARTIAL_FILE,
  NEWSFEED_ERROR_FETCH,
  NEWSFEED_ERROR_HTTP,
  NEWSFEED_ERROR_FILE,
  NEWSFEED_ERROR_PUT,
  NEWSFEED_ERROR_MEMORY,
  NEWSFEED_ERROR_SSL,
  NEWSFEED_ERROR_LDAP,
  NEWSFEED_ERROR_UNSUPPORTED_PROTOCOL
};

struct newsfeed {
  char * feed_url;
  char * feed_title;
  char * feed_description;
  char * feed_language;
  char * feed_author;
  char * feed_generator;
  time_t feed_date;
  carray * feed_item_list;
  int feed_response_code;
  
  unsigned int feed_timeout;
};

struct newsfeed_item {
  char * fi_url;
  char * fi_title;
  char * fi_summary;
  char * fi_text;
  char * fi_author;
  char * fi_id;
  time_t fi_date_published;
  time_t fi_date_modified;
  struct newsfeed * fi_feed; /* owner */
  struct newsfeed_item_enclosure * fi_enclosure;
};

struct newsfeed_item_enclosure {
  char * fie_url;
  char * fie_type;
  size_t fie_size;
};

#endif
