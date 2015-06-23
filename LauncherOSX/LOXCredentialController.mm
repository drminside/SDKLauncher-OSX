//
//  LOXCredentialController.mm
//  LauncherOSX
//
//  Created by DRM inside, H.S. Lee on 2015-04-21
//
//  Copyright (c) 2015 Readium Foundation and/or its licensees. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation and/or
//  other materials provided with the distribution.
//  3. Neither the name of the organization nor the names of its contributors may be
//  used to endorse or promote products derived from this software without specific
//  prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.
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
    
    //두번째 팝업에서 복사하는 문제
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
    //ok 버튼을 눌렀을때
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
    //cancel 버튼을 눌렀을때
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

//인풋 컴포넌트 설정
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

//캔슬버튼 설정
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
//버튼 설정
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

//버튼핸들러 실행 함수
- (void)buttonFromIndex:(id) sender
{
    NSButton * btn = (NSButton *)sender;
    NSInteger idx = btn.tag;
    
    reqPtr->SetPressedButtonIndex(idx);
    
    //인덱스로 버튼 핸들러 실행
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
