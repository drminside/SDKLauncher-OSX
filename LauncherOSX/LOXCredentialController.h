//
//  LOXCredentialController.h
//  LauncherOSX
//
//  Created by 이헌섭 on 2015. 4. 22..
//  Copyright (c) 2015년 Boris Schneiderman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCP/authentication_handler.h"

@interface LOXCredentialController : NSWindowController

@property (weak) IBOutlet NSView *credentialView;

- (void)openDlgFromCredentialRequest:(ePub3::CredentialRequest&)request;

@end
