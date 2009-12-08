/*

Special class, initializers for windows
*/

#ifdef HAVE_CONFIG_H
#	include <config.h>
#endif

#include <winsock2.h>

#ifdef _MSC_VER
#include "mailstream_ssl_private.h"
#include "mmapstring_private.h"
#endif

class win_init {
  public:
	win_init() { 

		wsocket_init();

#ifdef _MSC_VER
		/* Initialise Mutexs */
		mmapstring_init_lock();
		mailstream_ssl_init_lock();
#endif
	}
	~win_init() {
		WSACleanup();
	}

  private:
    WSADATA winsockData;

	void wsocket_init() {
	    int success = WSAStartup((WORD)0x0101, &winsockData);
		if (success != 0)
		{
			throw "Cannot startup windows sockets api.";
		}
	}

};

/* Initialise  */
static win_init windows_startup;

