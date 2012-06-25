     __    __     ______     __     __         ______     ______     ______     ______    
    /\ "-./  \   /\  __ \   /\ \   /\ \       /\  ___\   /\  __ \   /\  == \   /\  ___\   
    \ \ \-./\ \  \ \  __ \  \ \ \  \ \ \____  \ \ \____  \ \ \/\ \  \ \  __<   \ \  __\   
     \ \_\ \ \_\  \ \_\ \_\  \ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \ \_____\ 
      \/_/  \/_/   \/_/\/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 
                                                                                      

Getting Started
---------------

First checkout the code and pulldown the required dependencies as submodules:

    git clone https://github.com/mronge/MailCore.git
    cd MailCore/
    git submodule init
    git submodule update

Now open up MailCore.xcodeproj and build either the iOS static library or the Mac OS X framework depending on your needs.

Upgrading from previous version
-------
TODO:Fill this out, right now these are just notes

- Not backwards compatible
- fetchBody -> fetchBodyStructure
- New methods for fetching message lists
- Both - (NSSet *)messageObjectsFromIndex:(unsigned int)start toIndex:(unsigned int)end and - (NSSet *)messageListWithFetchAttributes:(NSArray *)attributes are gone.
- Moved to NSError
- Message to, from, sender, bcc, cc, subject are nil when not downloaded or message doesn't have them
- Changed how UID is stored, now just an integer, UID validity is separate


Contact
-------

If you have any questions contact me:

Matt Ronge

mronge@mronge.com
