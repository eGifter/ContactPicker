#import "ContactPicker.h"
#import <Cordova/CDVAvailability.h>

@implementation ContactPicker
@synthesize callbackID;

#pragma mark - Public interface

- (void) chooseEmailContact:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    [self checkAdressBookAccessWithCallback:^{
        [self showEmailAddressPicker];
    }];
}

- (void) choosePhoneContact:(CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    
    [self checkAdressBookAccessWithCallback:^{
        [self showSMSPicker];
    }];
}

-(void)showEmailAddressPicker {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = @[CNContactEmailAddressesKey];
    
    [self presentViewController:contactPicker animated:YES completion:nil];
}

-(void)showSMSPicker {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
    
    [self presentViewController:contactPicker animated:YES completion:nil];
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    [picker dismissViewControllerAnimated:true completion:nil];

    NSMutableDictionary* contact = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if ([contactProperty.key isEqualToString:CNContactEmailAddressesKey]) {
        [contact setObject:contactProperty.value forKey: @"email"];
    }
    
    if ([contactProperty.key isEqualToString:CNContactPhoneNumbersKey]) {
        CNPhoneNumber *phoneNumber = contactProperty.value;
        [contact setObject:phoneNumber.stringValue forKey: @"selectedPhone"];
    }

    [self respondToJS: contact];
}

#pragma mark - Address Book Access

- (void)checkAdressBookAccessWithCallback:(void (^)(void))callback {
    [self requestAccessWithCallback:^(BOOL success) {
        if (success) {
            if (callback) {
                callback();
            }
        }
        else {
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                     messageAsString:@"People picker denied access"]
                                        callbackId:self.callbackID];
        }
    }];
}

- (void)requestAccessWithCallback:(void (^)(BOOL success))callback {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (callback) {
                callback(granted);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        if (callback) {
            callback(YES);
        }
    }
    else {
        if (callback) {
            callback(NO);
        }
    }
}

#pragma mark - Response

- (void)respondToJS:(NSMutableDictionary *)contact {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:contact]
                                callbackId:self.callbackID];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:contact];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

@end