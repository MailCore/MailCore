#ifndef IMAPDRIVER_TOOLS_PRIVATE_H

#define IMAPDRIVER_TOOLS_PRIVATE_H

#include "mail_cache_db.h"

int
imapdriver_get_cached_envelope(struct mail_cache_db * cache_db,
    MMAPString * mmapstr,
    mailsession * session, mailmessage * msg,
    struct mailimf_fields ** result);

int
imapdriver_write_cached_envelope(struct mail_cache_db * cache_db,
    MMAPString * mmapstr,
    mailsession * session, mailmessage * msg,
    struct mailimf_fields * fields);

int imap_error_to_mail_error(int error);

int imap_store_flags(mailimap * imap, uint32_t first, uint32_t last,
    struct mail_flags * flags);

int imap_fetch_flags(mailimap * imap,
    uint32_t indx, struct mail_flags ** result);

int imap_get_messages_list(mailimap * imap,
    mailsession * session, mailmessage_driver * driver,
    uint32_t first_index,
    struct mailmessage_list ** result);

#endif
