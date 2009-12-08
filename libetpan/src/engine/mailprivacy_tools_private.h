#ifndef MAILPRIVACY_TOOLS_PRIVATE_H

#define MAILPRIVACY_TOOLS_PRIVATE_H

#include <libetpan/mailmessage.h>
#include <libetpan/mailprivacy_types.h>

enum {
  NO_ERROR_PASSPHRASE = 0,
  ERROR_PASSPHRASE_COMMAND,
  ERROR_PASSPHRASE_FILE
};

int mailprivacy_spawn_and_wait(char * command, char * passphrase,
    char * stdoutfile, char * stderrfile,
    int * bad_passphrase);

#endif
