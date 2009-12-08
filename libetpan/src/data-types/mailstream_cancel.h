#ifndef MAILSTREAM_CANCEL_H

#define MAILSTREAM_CANCEL_H

#include "mailstream_cancel_types.h"

struct mailstream_cancel * mailstream_cancel_new(void);
void mailstream_cancel_free(struct mailstream_cancel * cancel);

int mailstream_cancel_cancelled(struct mailstream_cancel * cancel);
void mailstream_cancel_notify(struct mailstream_cancel * cancel);
void mailstream_cancel_ack(struct mailstream_cancel * cancel);
int mailstream_cancel_get_fd(struct mailstream_cancel * cancel);

#endif
