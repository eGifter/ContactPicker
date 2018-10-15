#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ContactsUI/ContactsUI.h>
#import <Cordova/CDVPlugin.h>

@interface ContactPicker : CDVPlugin <CNContactPickerDelegate>

@property(strong) NSString* callbackID;

- (void) chooseEmailContact:(CDVInvokedUrlCommand*)command;

- (void) choosePhoneContact:(CDVInvokedUrlCommand*)command;

@end
