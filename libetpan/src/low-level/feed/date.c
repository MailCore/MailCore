#include <time.h>
#include <ctype.h>
#include <string.h>
#ifndef WIN32
#include <inttypes.h>
#endif

#include "mailimf.h"
#include "timeutils.h"

/*
YYYYMMDDThhmmss
YYYYMMDDThhmmssZ
YYYYMMDDThhmmss±hhmm
YYYYMMDDThhmmss±hh

YYYY-MM-DDThh:mm:ss
YYYY-MM-DDThh:mm:ssZ
YYYY-MM-DDThh:mm:ss±hh:mm
YYYY-MM-DDThh:mm:ss±hh
*/


/*
basic_format_parse()

YYYYMMDDThhmmss
YYYYMMDDThhmmssZ
YYYYMMDDThhmmss±hhmm
YYYYMMDDThhmmss±hh
*/

static time_t basic_format_parse(const char * str)
{
  int r;
  size_t len;
  size_t current_index;
  uint32_t value;
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
  int offset;
  int apply_offset;
  struct tm ts;
  int local_time;
  
  len = strlen(str);
  current_index = 0;
  
  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  day = value % 100;
  value /= 100;
  month = value % 100;
  value /= 100;
  year = value;
  
  r = mailimf_char_parse(str, len, &current_index, 'T');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;

  second = value % 100;
  value /= 100;
  minute = value % 100;
  value /= 100;
  hour = value;
  
  apply_offset = 0;
  offset = 0;
  r = mailimf_char_parse(str, len, &current_index, 'Z');
  if (r == MAILIMF_NO_ERROR) {
    /* utc */
    offset = 0;
    apply_offset = 1;
  }
  
  if (r != MAILIMF_NO_ERROR) {
    int offset_hour;
    int offset_minute;
    
    r = mailimf_char_parse(str, len, &current_index, '+');
    if (r == MAILIMF_NO_ERROR) {
      size_t last_index;
      
      last_index = current_index;
      r = mailimf_number_parse(str, len, &current_index, &value);
      if (r != MAILIMF_NO_ERROR)
        return (time_t) -1;
      if (current_index - last_index == 2) {
        offset_hour = value;
        offset_minute = 0;
      }
      else {
        offset_minute = value % 100;
        value /= 100;
        offset_hour = value;
      }
      offset = offset_hour * 3600 + offset_minute;
      apply_offset = 1;
    }
  }
  
  if (r != MAILIMF_NO_ERROR) {
    int offset_hour;
    int offset_minute;
    
    r = mailimf_char_parse(str, len, &current_index, '-');
    if (r == MAILIMF_NO_ERROR) {
      size_t last_index;
      
      last_index = current_index;
      r = mailimf_number_parse(str, len, &current_index, &value);
      if (r != MAILIMF_NO_ERROR)
        return (time_t) -1;
      if (current_index - last_index == 2) {
        offset_hour = value;
        offset_minute = 0;
      }
      else {
        offset_minute = value % 100;
        value /= 100;
        offset_hour = value;
      }
      offset = - (offset_hour * 3600 + offset_minute);
      apply_offset = 1;
    }
  }
  
  local_time = 0;
  if (r != MAILIMF_NO_ERROR) {
    local_time = 1;
  }
  
  memset(&ts, 0, sizeof(ts));
  
  ts.tm_sec = second;
  ts.tm_min = minute;
  ts.tm_hour = hour;
  ts.tm_mday = day;
  ts.tm_mon = month - 1;
  ts.tm_year = year - 1900;
  
  if (local_time) {
    value = mktime(&ts);
  }
  else {
    value = mail_mkgmtime(&ts);
    if (apply_offset)
      value -= offset;
  }
  
  return value;
}

/*
extended_format_parse()

YYYY-MM-DDThh:mm:ss
YYYY-MM-DDThh:mm:ssZ
YYYY-MM-DDThh:mm:ss±hh:mm
YYYY-MM-DDThh:mm:ss±hh
*/

static time_t extended_format_parse(const char * str)
{
  int r;
  size_t len;
  size_t current_index;
  uint32_t value;
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;
  int offset;
  int apply_offset;
  struct tm ts;
  int local_time;
  
  len = strlen(str);
  current_index = 0;
  
  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  year = value;
  
  r = mailimf_char_parse(str, len, &current_index, '-');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;

  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  month = value;
  
  r = mailimf_char_parse(str, len, &current_index, '-');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  day = value;
  
  r = mailimf_char_parse(str, len, &current_index, 'T');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  hour = value;
  
  r = mailimf_char_parse(str, len, &current_index, ':');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;

  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  minute = value;
  
  r = mailimf_char_parse(str, len, &current_index, ':');
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;

  r = mailimf_number_parse(str, len, &current_index, &value);
  if (r != MAILIMF_NO_ERROR)
    return (time_t) -1;
  
  second = value;
  
  apply_offset = 0;
  offset = 0;
  r = mailimf_char_parse(str, len, &current_index, 'Z');
  if (r == MAILIMF_NO_ERROR) {
    /* utc */
    offset = 0;
    apply_offset = 1;
  }
  
  if (r != MAILIMF_NO_ERROR) {
    r = mailimf_char_parse(str, len, &current_index, '+');
    if (r == MAILIMF_NO_ERROR) {
      int offset_hour;
      int offset_minute;
      
      r = mailimf_number_parse(str, len, &current_index, &value);
      if (r != MAILIMF_NO_ERROR)
        return (time_t) -1;
      
      offset_hour = value;
      
      r = mailimf_char_parse(str, len, &current_index, ':');
      if (r == MAILIMF_NO_ERROR) {
        r = mailimf_number_parse(str, len, &current_index, &value);
        if (r != MAILIMF_NO_ERROR)
          return (time_t) -1;
      
        offset_minute = value;
      }
      else {
        offset_minute = 0;
      }
      
      offset = offset_hour * 3600 + offset_minute;
      apply_offset = 1;
    }
  }
  
  if (r != MAILIMF_NO_ERROR) {
    
    r = mailimf_char_parse(str, len, &current_index, '-');
    if (r == MAILIMF_NO_ERROR) {
      int offset_hour;
      int offset_minute;
      
      r = mailimf_number_parse(str, len, &current_index, &value);
      if (r != MAILIMF_NO_ERROR)
        return (time_t) -1;
      
      offset_hour = value;
      
      r = mailimf_char_parse(str, len, &current_index, ':');
      if (r == MAILIMF_NO_ERROR) {
        r = mailimf_number_parse(str, len, &current_index, &value);
        if (r != MAILIMF_NO_ERROR)
          return (time_t) -1;
      
        offset_minute = value;
      }
      else {
        offset_minute = 0;
      }
      
      offset = offset_hour * 3600 + offset_minute;
      apply_offset = 1;
    }
  }
  
  local_time = 0;
  if (r != MAILIMF_NO_ERROR) {
    local_time = 1;
  }
  
  memset(&ts, 0, sizeof(ts));
  
  ts.tm_sec = second;
  ts.tm_min = minute;
  ts.tm_hour = hour;
  ts.tm_mday = day;
  ts.tm_mon = month - 1;
  ts.tm_year = year - 1900;
  
  if (local_time) {
    value = mktime(&ts);
  }
  else {
    value = mail_mkgmtime(&ts);
    if (apply_offset)
      value -= offset;
  }
  
  return value;
}

time_t newsfeed_iso8601_date_parse(const char * str)
{
  time_t value;

  value = basic_format_parse(str);
  if (value != (time_t) -1) {
    return value;
  }
  
  value = extended_format_parse(str);
  if (value != (time_t) -1) {
    return value;
  }
  
  return (time_t) -1;
}
