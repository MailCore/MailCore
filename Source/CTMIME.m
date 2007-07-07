#import "CTMIME.h"

@implementation CTMIME
- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	return nil;
}

- (void)dealloc	{
	[super dealloc];
}


- (id)content {
	return nil;
}

- (struct mailmime *)buildMIMEStruct {
	return NULL;
}

- (NSString *)render {
	MMAPString * str = mmap_string_new("");
	int col = 0;
	int err = 0;
 	NSString *resultStr;
	
	mailmime_write_mem(str, &col, [self buildMIMEStruct]);
	err = mmap_string_ref(str);
	assert(err == 0);
	resultStr = [[NSString alloc] initWithBytes:str->str length:str->len encoding:NSASCIIStringEncoding];
	mmap_string_free(str);
	return [resultStr autorelease];
}
@end
