//
//  LOXCredentialController.mm
//  LauncherOSX
//
//  Created by DRM inside Development Team on 2015-04-16.
//  ( T.H. Kim, H.D. Yoon, H.S. Lee and C.H. Yu )
//
//  Copyright (c) 2015 The Readium Foundation and contributors. All rights reserved.
//
//  The Readium SDK is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

#import "LOXCredentialController.h"
#import "LOXAppDelegate.h"
#import "LCP/authentication_handler.h"

#import <QuartzCore/CoreAnimation.h>

@interface LOXCredentialController ()

@end

@implementation LOXCredentialController
{
    ePub3::CredentialRequest *reqPtr;
    NSMutableDictionary *credentialDictionary;
}
@synthesize credentialView = _credentialView;

NSWindow *window_main;

- (void)awakeFromNib
{
}

- (void)openDlgFromCredentialRequest:(ePub3::CredentialRequest&)request
{
    reqPtr = &request;
    
    credentialDictionary = [[NSMutableDictionary alloc] init];
    
    std::size_t listNum = request.GetComponentCount();
    
    NSInteger height = 112;
    NSInteger widith = 420;
    
    NSWindow *credentialDlg = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, widith, height)
                                                          styleMask:NSTitledWindowMask
                                                            backing:NSBackingStoreBuffered
                                                              defer:NO];
    
    
    NSView *mainView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, widith, height)];
    [credentialDlg.contentView addSubview:mainView];
    
    NSString *title = [NSString stringWithUTF8String:(request.GetTitle().c_str())];
    NSString *message = [NSString stringWithUTF8String:(request.GetMessage().c_str())];
    [credentialDlg setTitle:title];
    
    NSButton *okBtn =[[NSButton alloc] initWithFrame:NSMakeRect(319, 18, 80, 27)];
    okBtn.bezelStyle = NSRoundedBezelStyle;
    [okBtn setTitle:@"Ok"];
    [okBtn setTarget:self];
    [okBtn setAction:@selector(buttonOK:)];
    [mainView addSubview:okBtn];
    
    NSTextField *messageFd = [[NSTextField alloc] initWithFrame:NSMakeRect(37, 60, 250, 25)];
    [messageFd setStringValue:message];
    [messageFd setBezeled:NO];
    [messageFd setDrawsBackground:NO];
    [messageFd setEditable:NO];
    [messageFd setSelectable:NO];
    [messageFd setAlignment:NSCenterTextAlignment];
    [mainView addSubview:messageFd];
    
    for(int i=2; i<listNum; i++){
        switch ((ePub3::CredentialRequest::Type)request.GetItemType(i)) {
            case ePub3::CredentialRequest::Type::Message:
            {
                break;
            }
            case (ePub3::CredentialRequest::Type::TextInput):
            {
                NSString *inputTitle = [NSString stringWithUTF8String:(request.GetItemTitle(i).c_str())];
                auto returnField = (NSTextField *)[self addCredentialInputWithTitle:inputTitle
                                                                              value:[NSString stringWithUTF8String:(request.GetDefaultValue(i).c_str())]
                                                                                idx:i
                                                                     isPasswordType:false
                                                                           mainView:mainView
                                                                       parentHeight:height];
                
                [credentialDictionary setObject:(NSTextField *)returnField forKey:title];
                
                break;
            }
            case (ePub3::CredentialRequest::Type::MaskedInput):
            {
                NSString *inputTitle = [NSString stringWithUTF8String:(request.GetItemTitle(i).c_str())];
                auto returnField = (NSSecureTextField *) [self addCredentialInputWithTitle:[NSString stringWithUTF8String:(request.GetItemTitle(i).c_str())]
                                                                                     value:[NSString stringWithUTF8String:(request.GetDefaultValue(i).c_str())]
                                                                                       idx:i
                                                                            isPasswordType:true
                                                                                  mainView:mainView
                                                                              parentHeight:height];
                
                [credentialDictionary setObject:(NSSecureTextField *)returnField forKey:inputTitle];
                break;
            }
            case (ePub3::CredentialRequest::Type::Button):
            {
                NSString *buttonTitle = [NSString stringWithUTF8String:(request.GetItemTitle(i).c_str())];
                if ([buttonTitle isEqualToString:@"Cancel"]) {
                    [self addCancelButtonInputWithTitle:buttonTitle
                                                    idx:i
                                              setAction:@selector(buttonCancel:)
                                               mainView:mainView
                                           parentHeight:height];
                    
                } else {
                    [self addButtonInputWithTitle:buttonTitle
                                              idx:i
                                        setAction:@selector(buttonFromIndex:)
                                         mainView:mainView
                                     parentHeight:height];
                }
                break;
            }
            default:
                break;
        }
        
    }
    
    window_main = credentialDlg;
    
    [NSApp beginSheet: credentialDlg
       modalForWindow: self.window
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    NSInteger result = [NSApp runModalForWindow: credentialDlg];

    //ok
    if (result == NSModalResponseStop)
    {
        NSArray *keys = [credentialDictionary allKeys];
        for(int i = 0 ; i < [keys count] ; i++)
        {
            auto itemObj = credentialDictionary[keys[i]];
            
            //코어에서 처리할 경우 setCredentialItem에 인자를 넣을때 ui에 대한 처리, stopModal에 대한 별도의 처리가 필요함
            NSString * item = [itemObj stringValue];
            reqPtr->SetCredentialItem(ePub3::string([(NSString *)keys[i] UTF8String]), ePub3::string([item UTF8String]));
        }
        reqPtr->SignalCompletion();
    }
    //cancel
    else if (result == NSModalResponseAbort)
    {
        reqPtr->SignalCompletion();
    }
    else
    {
        if(result == NSModalResponseContinue)
            [NSApp stopModal];
    }
    
    [NSApp endSheet: credentialDlg];
    [credentialDlg orderOut:self];
    
}

//set credential component
- (id)addCredentialInputWithTitle:(NSString *)title value:(NSString *)value idx:(NSInteger)idx isPasswordType:(BOOL)isPwd mainView:(NSView *) mainView parentHeight:(NSInteger)pHeight
{
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(34, 65, 80, 22)];
    [label setStringValue:title];
    [label setFont:[NSFont fontWithName:@"Menlo" size:13]];
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    [mainView addSubview:label];
    
    if (!isPwd)
    {
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(116, 65, 275, 22)];
        [input setStringValue:value];
        [mainView addSubview:input];
        return input;
    }
    else
    {
        NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(116, 65, 275, 22)];
        [input setStringValue:value];
        [mainView addSubview:input];
        return input;
    }
}

//set cancel button
- (void)addCancelButtonInputWithTitle:(NSString*)title idx:(NSInteger)idx setAction:(SEL)action mainView:(NSView *)mainView parentHeight:(NSInteger)pHeight
{
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(240, 18, 84, 27)];
    button.bezelStyle = NSRoundedBezelStyle;
    [button setTitle:title];
    [button setTarget:self];
    [button setAction:action];
    [button setTag:idx];
    [mainView addSubview:button];
}

//set button
- (void)addButtonInputWithTitle:(NSString*)title idx:(NSInteger)idx setAction:(SEL)action mainView:(NSView *)mainView parentHeight:(NSInteger)pHeight
{
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(29, 18, 144, 27)];
    button.bezelStyle = NSRoundedBezelStyle;
    [button setTitle:title];
    [button setTarget:self];
    [button setAction:action];
    [button setTag:idx];
    [mainView addSubview:button];
}

//run button handler function
- (void)buttonFromIndex:(id) sender
{
    NSButton * btn = (NSButton *)sender;
    NSInteger idx = btn.tag;
    
    reqPtr->SetPressedButtonIndex(idx);
    
    auto t = reqPtr->GetButtonHandler(idx);
    t(nullptr, idx);
    

}

- (void)buttonCancel:(id)sender
{
    
    NSButton * btn = (NSButton *)sender;
    NSInteger idx = btn.tag;
    
    reqPtr->SetPressedButtonIndex(idx);
    
    auto a = reqPtr->GetButtonHandler(idx);
    if(a != nullptr) {
        a(nullptr, idx);
    }
    
    [NSApp abortModal];
}


- (void)buttonOK:(id)sender
{
    [NSApp stopModal];
}



@end
