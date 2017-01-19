/*I want to move and copy a mail to another folder,so I invoke the methods :- (BOOL)copyMessageWithUID:(NSUInteger)uid 
toPath:(NSString *)path and - (BOOL)moveMessageWithUID:(NSUInteger)uid toPath:(NSString *)path.The parameter for path is 
chinese string(UTF8).However,the two methods didnot work because they donot have the codes for converting UTF8String into
UTF7String.In order to support the chinese string path name,I modify the two methods as follows:*/

- (BOOL)copyMessageWithUID:(NSUInteger)uid toPath:(NSString *)path {
    BOOL success = [self connect];
    if (!success) {
        return NO;
    }

//    const char *mbPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    char mbPath[MAX_PATH_SIZE];
    [self getUTF7String:mbPath fromString:path];
    int err = mailsession_copy_message([self folderSession], uid, mbPath);
    if (err != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(err);
        return NO;
    }
    return YES;
}

- (BOOL)moveMessageWithUID:(NSUInteger)uid toPath:(NSString *)path {
    BOOL success = [self connect];
    if (!success) {
        return NO;
    }

//    const char *mbPath = [path cStringUsingEncoding:NSUTF8StringEncoding];
    char mbPath[MAX_PATH_SIZE];
    [self getUTF7String:mbPath fromString:path];
    int err = mailsession_move_message([self folderSession], uid, mbPath);
    if (err != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromIMAPCode(err);
        return NO;
    }
    return YES;
}

