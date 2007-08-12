#import <Cocoa/Cocoa.h>
#import "CTCoreAccount.h"
#import "CTCoreFolder.h"
#import "CTCoreMessage.h"
#import "CTSMTPConnection.h"
#import "CTCoreAddress.h"
#import "MailCoreTypes.h"

#import "CTMIMEFactory.h"

const NSString *filePrefix = @"/Users/local/Projects/MailCore/";

int main( int argc, char *argv[ ] )
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	CTCoreMessage *msg = [[CTCoreMessage alloc] initWithFileAtPath:[NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/mime-tests/imagetest"]];
//	CTMIME *mime = [CTMIMEFactory createMIMEWithMIMEStruct:[msg messageStruct]->msg_mime forMessage:[msg messageStruct]];
	
	
	CTCoreAccount *account = [[CTCoreAccount alloc] init];
	CTCoreFolder *folder;
////	CTCoreFolder *inbox, *newFolder, *archive;
////	CTCoreMessage *msgOne;
////	
//
//	MailCoreEnableLogging();
	[account connectToServer:@"mail.theronge.com" port:143 connectionType:CONNECTION_TYPE_STARTTLS 
				authType:IMAP_AUTH_TYPE_PLAIN login:@"mronge" password:@""];
	
	folder = [account folderWithPath:@"INBOX.Trash"];
	for (CTCoreMessage *msg in [folder messageObjectsFromIndex:0 toIndex:10]) {
		NSLog(@"%@ / %@", msg.subject, msg.uid);
	}
	
	CTCoreMessage *msg = [folder messageWithUID:@"1163997146-103"];
	unsigned int flags = [folder flagsForMessage:msg];
	flags = flags | CTFlagDeleted;
	[folder setFlags:flags forMessage:msg];
	[folder expunge];
	
	
	//[folder copyMessageWithUID:@"1163978737-3691" toFolderWithPath:@"INBOX.Trash"];
	//NSLog(@"%d", [folder totalMessageCount]);
/*	for (CTCoreMessage *msg in [folder messageObjectsFromIndex:10 toIndex:18]) {
		NSLog(@"%d", [msg sequenceNumber]);
		NSLog([msg uid]);
	}*/
	//	14
	//1163978737-3518
	//CTCoreMessage *msg = [folder messageWithUID:@"1163978737-3518"];
	//NSLog([msg subject]);
//	NSLog(@"%d", [folder sequenceNumberForUID:@"1163978737-3518"]);
//	[account release];
//	CTCoreMessage *msg;
//	NSEnumerator *enumer = [set objectEnumerator];
//	while ((msg == [enumer nextObject])) {
//		
//	}
//	//NSLog(@"%@", [inbox messageObjectsFromIndex:500 toIndex:600]);
//	
//	msgOne = [inbox messageWithUID:@"1146070022-553"];
//	NSLog(@"%@ %@", [msgOne flags], [msgOne subject]);
//	NSMutableDictionary *flags = [[msgOne flags] mutableCopy];
//	[flags setObject:CTFlagSet forKey:CTFlagSeen];
//	[msgOne setFlags:flags];
	//[inbox disconnect];
	//	[inbox expunge];

	/*
	NSSet *messageList = [inbox messageListFromIndex:nil];
	NSLog(@"Message List....");
	NSLog(@"%@",messageList);
	NSEnumerator *enumerator = [messageList objectEnumerator];
	id obj;
	CTCoreMessage *tempMsg;
	while(obj = [enumerator nextObject])
	{
		tempMsg = [inbox messageWithUID:obj];
		NSLog(@"%@",[tempMsg subject]);
	}
	
	NSSet *archiveMessageList;
	archive = [account folderWithPath:@"INBOX.TheArchive"];
	archiveMessageList = [archive messageListFromIndex:nil];
	NSEnumerator *objEnum = [archiveMessageList objectEnumerator];
	id aMessage;

	NSLog(@"INBOX.TheArchive");
	NSLog(@"%@",archiveMessageList);
	while(aMessage = [objEnum nextObject])
	{
		tempMsg = [archive messageWithUID:aMessage];
		NSLog(@"%@",[tempMsg subject]);
		NSLog(@"%@",[tempMsg from]);
		NSLog(@"%@",[tempMsg to]);
	}
	
	msgOne =[inbox messageWithUID:@"1142229815-9"];
	[msgOne setBody:@"Muhahahaha. Libetpan!"];
	[msgOne setSubject:@"Hahaha"];
	[msgOne setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Bob" email:@"mronge2@uiuc.edu"]]];
	[msgOne setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Matt" email:@"mronge@theronge.com"]]];
	*/
	
	//CTCoreAddress *addr = [CTCoreAddress address];
	//[addr setEmail:@"Test"];
	//[addr setEmail:@"Test2"];
	
	/* GMAIL Test */
	
//	MailCoreEnableLogging();
//	
//	CTCoreMessage *msgOne = [[CTCoreMessage alloc] init];
//	[msgOne setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:@"Bob" email:@"mronge@theronge.com"]]];
//	[msgOne setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:@"test" email:@"test@test.com"]]];
//	[msgOne setBody:@"Test"];
//	[msgOne setSubject:@"Subject"];	
//	[CTSMTPConnection sendMessage:msgOne server:@"mail.theronge.com" username:@"mronge" password:@"" port:25 useTLS:YES shouldAuth:YES];
	//[CTSMTPConnection sendMessage:msgOne server:@"mail.dls.net" username:@"" password:@"" port:25 useTLS:NO shouldAuth:NO];
	//[archive disconnect];
	//[account disconnect];
	//[account release];
	
	[pool release];
		
	//while(1) {}
	return 0;
}
