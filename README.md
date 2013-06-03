     __    __     ______     __     __         ______     ______     ______     ______    
    /\ "-./  \   /\  __ \   /\ \   /\ \       /\  ___\   /\  __ \   /\  == \   /\  ___\   
    \ \ \-./\ \  \ \  __ \  \ \ \  \ \ \____  \ \ \____  \ \ \/\ \  \ \  __<   \ \  __\   
     \ \_\ \ \_\  \ \_\ \_\  \ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\ \_\  \ \_____\ 
      \/_/  \/_/   \/_/\/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_/ /_/   \/_____/ 
                                                                                      

## What is MailCore

MailCore is a Mac and iOS library designed to ease the pain of dealing with e-mail protocols. MailCore makes the process of sending e-mail easy by hiding the nasty details like MIME composition from you. Instead, there is a single method required to send a message. Checking e-mail on an IMAP server is a more complex beast, but MailCore makes the job much simpler by presenting everything as a set of objects like Messages, Folders and Accounts.

## Example

This example shows how you can send email using MailCore.

```obj-c
CTCoreMessage *msg = [[CTCoreMessage alloc] init];
CTCoreAddress *toAddress = [CTCoreAddress addressWithName:@"Monkey"
                                                    email:@"monkey@monkey.com"];
[msg setTo:[NSSet setWithObject:toAddress]];
[msg setBody:@"This is a test message!"];
 
NSError *error;
BOOL success = [CTSMTPConnection sendMessage:testMsg 
                                      server:@"mail.test.com"
                                    username:@"test"
                                    password:@"test"
                                        port:587
                              connectionType:CTSMTPConnectionTypeStartTLS
                                     useAuth:YES
                                       error:&error];
```


## Getting the code

First checkout the code and pulldown the required dependencies as submodules:

    git clone https://github.com/mronge/MailCore.git
    cd MailCore/
    git submodule update --init

Now open up MailCore.xcodeproj and build either the iOS static library or the Mac OS X framework depending on your needs.

## Adding MailCore to Your iOS Project

1. First checkout the latest code and make sure you get the required submodules
2. Locate MailCore.xcodeproj and add it to your project as a subproject. You can do this by dragging the Mailcore.xcodeproj file into your Xcode project.
3. Navigate to your app’s target and switch to your app’s Build Phases. Once in Build Phases expand “Link Binary With Libraries” and click the + button. And add these libraries:
```
   libmailcore.a
   libssl.a
   libsasl2.a
   libcrypto.a
   libiconv.dylib
   CFNetwork.framework
```

4. Add “MailCore iOS” under “Target Dependencies”
5. Under your app’s target, switch to Build Settings. Locate “Header Search Paths” in the Build Settings and add `"$(BUILT_PRODUCTS_DIR)/../../include"`
6. You are now ready to use MailCore. To use MailCore add `#import <MailCore/MailCore.h>` to the top of your Objective-C files.

## Adding MailCore to Your Mac Project

1. First checkout the latest code and make sure you get the required submodules
2. Locate MailCore.xcodeproj and add it to your project as a subproject. You can do this by dragging the Mailcore.xcodeproj file into your Xcode project.
3. Navigate to your app’s target and switch to your app’s Build Phases. Once in Build Phases expand “Link Binary With Libraries” and click the + button. From there add MailCore.framework.
4. While still under Build Phases click “Add Build Phase” in the lower right and select “Add Copy Files”. A new copy files phase will be added, make sure the destination is set to “Frameworks”. Now add MailCore.framework to that copy files phase by using the + button.
5. Add “MailCore” under “Target Dependencies”
6. You are now ready to use MailCore. To use MailCore add `#import <MailCore/MailCore.h>` to the top of your Objective-C files.

## More Docs

* [Getting Started](https://github.com/MailCore/MailCore/wiki/Getting-Started)
* [FAQ](https://github.com/MailCore/MailCore/wiki/FAQ)
* [API Docs](http://libmailcore.com/api/)
* [Wiki](https://github.com/MailCore/MailCore/wiki)

## Consulting

Consulting services are available via [Central Atomics](http://www.centralatomics.com). At Central Atomics we have years of experience working on email apps. If you need custom e-mail functionality developed, please get in touch via our website.

Thanks,

Matt Ronge  
[@mronge](http://www.twitter.com/mronge)
