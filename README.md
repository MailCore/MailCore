     __    __     ______     __     __         ______     ______     ______     ______    
    /\ "-./  \   /\  __ \   /\ \   /\ \       /\  ___\   /\  __ \   /\  == \   /\  ___\   
    \ \ \-./\ \  \ \  __ \  \ \ \  \ \ \____  \ \ \____  \ \ \/\ \  \ \  __<   \ \  __\   
     \ \_\ \ \_\  \ \_\ \_\  \ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \ \_____\ 
      \/_/  \/_/   \/_/\/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 
                                                                                      

##Getting the code

First checkout the code and pulldown the required dependencies as submodules:

    git clone https://github.com/mronge/MailCore.git
    cd MailCore/
    git submodule update --update

Now open up MailCore.xcodeproj and build either the iOS static library or the Mac OS X framework depending on your needs.

##Website

The official site contains documentation, FAQs, and step by step instructions on how to include MailCore

http://www.libmailcore.com

## Migrating to Version 1.0

The latest version of MailCore is no longer backwards compatible with earlier versions. I tried to keep backwards compatibility, but it became too complex, sorry :(

The biggest change is that exceptions are no longer used. Instead each method either returns a BOOL or an object that can be checked for success. If an error occurs each object has a `- (NSError *)lastError` method that can be consulted.

Here are a list of major changes:

* The method `- (int)fetchBody` has been renamed to `- (BOOL)fetchBodyStructure`
* The methods `messageObjectsFromIndex:toIndex:` and `messageListWithFetchAttributes:` have both been removed. They've been replaced by the new and improved `messagesFromSequenceNumber:to:withFetchAttributes:` and `messagesFromUID:to:withFetchAttributes:`. Please see the header file CTCoreFolder.m for details.
- NSException is no longer used, instead NSError is used.
- A CTCoreMessage's to, from, sender, bcc, cc, and subject values are nil when they have not been downloaded or message doesn't have them
- Message UIDs are now NSUIntegers instead of NSStrings
- `- (BOOL)isUIDValid:(NSString *)uid` has been removed. Instead check your uid validity value manually

Thanks,

Matt Ronge 
