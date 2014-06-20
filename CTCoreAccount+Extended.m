//
//  CTCoreAccount+Extended.m
//  MailCore
//
//  Created by Davide Gullo on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <libetpan/mailimap_types.h>
#import "CTCoreAccount+Extended.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"

@implementation CTCoreAccount (Extended)

-(NSMutableDictionary *) foldersWithAttributes: (NSString*) attribute {
    
    struct mailimap_mailbox_list* mailboxStruct;
    clist *allList;
    clistiter* cur;
    clistiter* attrCur;
    NSString* attr;
    clist *attrList;
    
    NSString *mailboxNameObject;
	char *mailboxName;
	int err;
	
	NSMutableDictionary *allFolders = [NSMutableDictionary dictionary];
    
	
	/* Retrive data use xlist command*/
	err = mailimap_xlist([self session], "", "*", &allList);		
    if (err != MAILIMAP_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(err);
        return nil;
    }
	else if (clist_isempty(allList))
	{
        self.lastError = MailCoreCreateErrorFromIMAPCode(err);
        return nil;
	}
	for(cur = clist_begin(allList); cur != NULL; cur = cur->next)
	{
        
         
        mailboxStruct = cur->data;        
        switch (mailboxStruct -> mb_flag ->mbf_sflag) {
            case MAILIMAP_MBX_LIST_SFLAG_NOSELECT:
                attr = @"Noselect ";
                break;
                
            default:
                attr = @"";

                break;
        }
        
        attrList = mailboxStruct -> mb_flag ->mbf_oflags;
        if(clist_isempty(attrList) )
        {
            continue;
        }
        
        for(attrCur = clist_begin(attrList); attrCur != NULL; attrCur = attrCur -> next) {
            
            struct mailimap_mbx_list_oflag* ignoreflag =  attrCur -> data;

            //printf("%s \n", ignoreflag ->);             
             attr = [attr stringByAppendingFormat:@"%@ ", [NSString stringWithCString:ignoreflag -> of_flag_ext encoding:NSUTF8StringEncoding]];
            
        }
   
		/* Compare with parameter*/
		if(attribute != nil && [attr rangeOfString:attribute].location == NSNotFound)
		{
			continue;
		}
		//NSLog(@"%@", attr);
        
		mailboxName = mailboxStruct->mb_name;
		mailboxNameObject = (NSString *) CFStringCreateWithCString(NULL, mailboxName, kCFStringEncodingUTF7_IMAP);
		[mailboxNameObject autorelease];

        //NSMutableArray* arr = [allFolders objectForKey:attr];
        //if (arr == nil) {
        //        arr = [NSMutableArray array];            
        //}
        //[arr addObject:mailboxNameObject];
        [allFolders setObject:attr forKey:mailboxNameObject];
        
	}
	mailimap_list_result_free(allList);
	return allFolders;  
}

@end
