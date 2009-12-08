#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "newsfeed_private.h"

#include <string.h>

#include "mailimf.h"
#include "timeutils.h"

static inline time_t get_date(struct mailimf_date_time * date_time)
{
  struct tm tmval;
  time_t timeval;
  
  tmval.tm_sec  = date_time->dt_sec;
  tmval.tm_min  = date_time->dt_min;
  tmval.tm_hour = date_time->dt_hour;
  tmval.tm_sec  = date_time->dt_sec;
  tmval.tm_mday = date_time->dt_day;
  tmval.tm_mon  = date_time->dt_month - 1;
  tmval.tm_year = date_time->dt_year - 1900;
  
  timeval = mail_mkgmtime(&tmval);
  
  timeval -= date_time->dt_zone * 36;
  
  return timeval;
}

time_t newsfeed_rfc822_date_parse(char * text)
{
  time_t date;
  struct mailimf_date_time * date_time;
  size_t current_pos;
  int r;
  
  date = (time_t) -1;
  current_pos = 0;
  r = mailimf_date_time_parse(text, strlen(text),
      &current_pos, &date_time);
  if (r == MAILIMF_NO_ERROR) {
    date = get_date(date_time);
    mailimf_date_time_free(date_time);
  }
  
  return date;
}
