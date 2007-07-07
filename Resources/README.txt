Licensed under BSD, see LICENSE.txt for more information.

MailCore by Matt Ronge
http://www.theronge.com
Based on LibEtPan and work done by Dinh Viet Hoa.


Known Issues
(Will be fixed eventually)
-------------
- MIME messages containing multipart/report parts aren't parsed correctly, part of the body is not shown.
- A crash occurs when sending a message with TLS, then sending it again without TLS, repeat over a few times and a crash will occur. Hopefully this won't affect anyone, if it does, let me know and I'll look into it again.
- Sometimes it will take a very long time for MailCore to timeout


To do
------

- Add support for more than just PLAIN authentication
- Add attachment support
- Add image support
- Add HTML support

Longer Term To Do
------------------
- Add support so that messages can be downloaded in chunks (this is a work in progress)
- Add support so that flags can be downloaded in chunks
- Add ACL support
- Add annotatemore support
