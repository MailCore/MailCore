#ifndef MAILSTREAM_CANCEL_TYPES_H

#define MAILSTREAM_CANCEL_TYPES_H

struct mailstream_cancel {
  int ms_cancelled;
  int ms_fds[2];
  void * ms_internal;
};

#endif
