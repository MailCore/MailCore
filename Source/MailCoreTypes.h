/* ========================= */
/* = List of Message Flags = */
/* ========================= */

#define CTFlagNew			@"NEW"
#define CTFlagSeen			@"SEEN"
#define CTFlagFlagged		@"FLAGGED"
#define CTFlagDeleted		@"DELETED"
#define CTFlagAnswered		@"ANSWERED"
#define CTFlagForwarded		@"FORWARDED"
#define CTFlagCancelled 	@"CANCELLED"
#define CTFlagExtensions	@"EXTENSIONS"

#define CTFlagSet			@"SET"
#define CTFlagNotSet		@"NOT_SET"

/* =========================== */
/* = List of Exception Types = */
/* =========================== */

#define CTMIMEParseError			@"MIMEParserError"
#define CTMIMEParseErrorDesc		@"An error occured during MIME parsing."

#define CTMIMEUnknownError			@"MIMEUnknownError"
#define CTMIMEUnknownErrorDesc		@"I don't know how to parse this MIME structure."

#define CTMemoryError	   			@"MemoryError"
#define CTMemoryErrorDesc  			@"Memory could not be allocated."
                           
#define CTLoginError	   			@"LoginError"
#define CTLoginErrorDesc   			@"The username or password you entered is invalid."
                           
#define CTUnknownError	   			@"UnknownError"

#define	CTMessageNotFound			@"MessageNotFound"
#define	CTMessageNotFoundDesc		@"The message could not be found."

#define	CTNoSubscribedFolders		@"NoSubcribedFolders"
#define	CTNoSubscribedFoldersDesc	@"There are not any subscribed folders."

#define	CTNoFolders					@"NoFolders"
#define	CTNoFoldersDesc				@"There are not any folders on the server."

#define	CTFetchError				@"FetchError"
#define	CTFetchErrorDesc			@"An error has occurred while fetching from the server."

#define	CTSMTPError					@"SMTPError"
#define	CTSMTPErrorDesc				@"An error has occurred while attempting to send via SMTP."

#define	CTSMTPSocket				@"SMTPSocket"
#define	CTSMTPSocketDesc			@"An error has occurred while attempting to open an SMTP socket connection."

#define	CTSMTPHello					@"SMTPHello"
#define	CTSMTPHelloDesc				@"An error occured while introducing ourselves to the server with the ehlo, or helo command."

#define	CTSMTPTLS					@"SMTPTLS"
#define	CTSMTPTLSDesc				@"An error occured while attempting to setup a TLS connection with the server."

#define	CTSMTPLogin					@"SMTPLogin"
#define	CTSMTPLoginDesc				@"The password or username is invalid."

#define	CTSMTPFrom					@"SMTPFrom"
#define	CTSMTPFromDesc				@"An error occured while sending the from address."

#define	CTSMTPRecipients			@"SMTPRecipients"
#define	CTSMTPRecipientsDesc		@"An error occured while sending the recipient addresses."

#define	CTSMTPData					@"SMTPData"
#define	CTSMTPDataDesc				@"An error occured while sending message data."