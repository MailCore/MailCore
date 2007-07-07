#import <Cocoa/Cocoa.h>

/*!
	@class	CTSMTPConnection
	This is not a class you instantiate! It has only one class method, and that is all you need to send e-mail.
	First use CTCoreMessage to compose an e-mail and then pass the e-mail to the method sendMessage: with
	the necessary server settings and CTSMTPConnection will send the message.
*/

@class CTCoreMessage, CTCoreAddress;

@interface CTSMTPConnection : NSObject {

}
/*!
	@abstract	This method...it sends e-mail.
	@param		message	Just pass in a CTCoreMessage which has the body, subject, from, to etc. that you want
	@param		server The server address
	@param		username The username, if there is none then pass in an empty string. For some servers you may
				have to specify the username as username@domain
	@param		password The password, if there is none then pass in an empty string.
	@param		port The port to use, the standard port is 25
	@param		useTLS Pass in YES, if you want to use SSL/TLS
	@param		useAuth Pass in YES if you would like to use SASL authentication
*/
+ (void)sendMessage:(CTCoreMessage *)message server:(NSString *)server username:(NSString *)username
					password:(NSString *)password port:(unsigned int)port useTLS:(BOOL)tls useAuth:(BOOL)auth;
@end
