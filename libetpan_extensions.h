//
//  libetpan_extensions.h
//  gmailbackup
//
//  Created by David Gelhar on 3/23/13.
//
//

#ifndef gmailbackup_libetpan_extensions_h
#define gmailbackup_libetpan_extensions_h

#include <mailimap_types.h>
#include <mailimap.h>
#include <mailimap_sender.h>
#include <mailimap_parser.h>

long gmailimap_append(mailimap * session, const char * mailbox,
		     struct mailimap_flag_list * flag_list,
		     struct mailimap_date_time * date_time,
		     const char * literal, size_t literal_size);
#endif
