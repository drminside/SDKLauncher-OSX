//
// Created by Boris Schneiderman on 2013-08-20.
// Copyright (c) 2013 Boris Schneiderman. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <ePub3/package.h>
#import "LOXMediaOverlay.h"
#import "LOXSmilModel.h"
#include "media-overlays_smil_data.h"

#import <ePub3/media-overlays_smil_utils.h>



@interface LOXMediaOverlay ()
//- (NSString *)getProperty:(NSString *)name fromPropertyHolder:(std::shared_ptr<ePub3::PropertyHolder>)sdkPropertyHolder;
@end

@implementation LOXMediaOverlay {

    NSMutableArray *_smilModels;
}

@synthesize smilModels = _smilModels;

- (id)initWithSdkPackage:(ePub3::PackagePtr)sdkPackage
{
    self = [super init];

    if(self) {

        auto ePubSmilModel = sdkPackage->MediaOverlaysSmilModel();

        auto narrator = ePubSmilModel->Narrator(); //sdkPackage->MediaOverlays_Narrator();
        self.narrator = [NSString stringWithUTF8String: narrator.c_str()];
        //NSLog(@"=== NARRATOR: [%s]", [self.narrator UTF8String]);

        auto activeClass = ePubSmilModel->ActiveClass(); //sdkPackage->MediaOverlays_ActiveClass();
        self.activeClass = [NSString stringWithUTF8String: activeClass.c_str()];
        //NSLog(@"=== ACTIVE-CLASS: [%s]", [self.activeClass UTF8String]);

        auto playbackActiveClass = ePubSmilModel->PlaybackActiveClass(); //sdkPackage->MediaOverlays_PlaybackActiveClass();
        self.playbackActiveClass = [NSString stringWithUTF8String: playbackActiveClass.c_str()];
        //NSLog(@"=== PLAYBACK-ACTIVE-CLASS: [%s]", [self.playbackActiveClass UTF8String]);

        self.duration = [NSNumber numberWithDouble: ePubSmilModel->DurationMillisecondsTotal() / 1000.0];
        //NSLog(@"=== TOTAL MO DURATION: %ldms", (long) floor([self.duration doubleValue] * 1000.0));

        _smilModels = [[NSMutableArray array] retain];

        auto count = ePubSmilModel->GetSmilCount();
        for (int i = 0; i < count; i++)
        {
            auto smilData = ePubSmilModel->GetSmil(i);

            LOXSmilModel * smil = [[LOXSmilModel alloc] init];

            smil.smilVersion = [NSString stringWithUTF8String: "3.0"];

            smil.duration = [NSNumber numberWithDouble: smilData->DurationMilliseconds() / 1000.0];

            auto item = smilData->ManifestItem();

            smil.id = [NSString stringWithUTF8String:item->Identifier().c_str()];
            smil.href = [NSString stringWithUTF8String:item->Href().c_str()];

            //NSLog(@"=== smil.id: [%s]", [smil.id UTF8String]);
            //NSLog(@"=== smil.href: [%s]", [smil.href UTF8String]);

            auto seq = smilData->Body();

            NSMutableDictionary *smilItem = [self parseTree_Sequence: seq];

            [smil addItem:smilItem];

            [_smilModels addObject:smil];
        }
    }

    return self;
}

- (NSMutableDictionary *) parseTree_Text:(const ePub3::SMILData::Text*)node
{
    NSMutableDictionary *smilItem = [NSMutableDictionary dictionary];

    smilItem[@"nodeType"] = [NSString stringWithUTF8String: node->Name().c_str()];

//NSLog(@"=== nodeType: [%s]", [smilItem[@"nodeType"] UTF8String]);

    std::string str("");
    str.append(node->SrcFile().c_str());
    if (!node->SrcFragmentId().empty())
    {
        str.append("#");
        str.append(node->SrcFragmentId().c_str());
    }

    smilItem[@"src"] = [NSString stringWithUTF8String: str.c_str()];

//    NSMutableArray *children = [NSMutableArray array];
//    smilItem[@"children"] = children;

    return smilItem;
}

- (NSMutableDictionary *) parseTree_Audio:(const ePub3::SMILData::Audio*)node
{
    NSMutableDictionary *smilItem = [NSMutableDictionary dictionary];

    smilItem[@"nodeType"] = [NSString stringWithUTF8String: node->Name().c_str()];

//NSLog(@"=== nodeType: [%s]", [smilItem[@"nodeType"] UTF8String]);

    std::string str("");
    str.append(node->SrcFile().c_str());
    if (!node->SrcFragmentId().empty())
    {
        str.append("#");
        str.append(node->SrcFragmentId().c_str());
    }

    smilItem[@"src"] = [NSString stringWithUTF8String: str.c_str()];

    smilItem[@"clipBegin"] = [NSNumber numberWithDouble: node->ClipBeginMilliseconds() / 1000.0];
    smilItem[@"clipEnd"] = [NSNumber numberWithDouble: node->ClipEndMilliseconds() / 1000.0];


//    NSMutableArray *children = [NSMutableArray array];
//    smilItem[@"children"] = children;

    return smilItem;
}

- (NSMutableDictionary *) parseTree_Parallel:(ePub3::SMILData::Parallel*)node
{
    NSMutableDictionary *smilItem = [NSMutableDictionary dictionary];

    smilItem[@"nodeType"] = [NSString stringWithUTF8String: node->Name().c_str()];

//NSLog(@"=== nodeType: [%s]", [smilItem[@"nodeType"] UTF8String]);

    std::string str("");
    str.append(node->TextRefFile().c_str());
    if (!node->TextRefFragmentId().empty())
    {
        str.append("#");
        str.append(node->TextRefFragmentId().c_str());
    }

    smilItem[@"textref"] = [NSString stringWithUTF8String: str.c_str()];

    smilItem[@"epubtype"] = [NSString stringWithUTF8String: node->Type().c_str()];

    NSMutableArray *children = [NSMutableArray array];

    auto textMedia = node->Text();
    if (textMedia != nullptr && textMedia->IsText())
    {
        NSMutableDictionary *text = [self parseTree_Text: textMedia];
        [children addObject:text];
    }

    auto audioMedia = node->Audio();
    if (audioMedia != nullptr && audioMedia->IsAudio())
    {
        NSMutableDictionary *audio = [self parseTree_Audio: audioMedia];
        [children addObject:audio];
    }

    smilItem[@"children"] = children;

    return smilItem;
}

- (NSMutableDictionary *) parseTree_Sequence:(const ePub3::SMILData::Sequence*)node
{
    NSMutableDictionary *smilItem = [NSMutableDictionary dictionary];

    smilItem[@"nodeType"] = [NSString stringWithUTF8String: node->Name().c_str()];

//NSLog(@"=== nodeType: [%s]", [smilItem[@"nodeType"] UTF8String]);

    std::string str("");
    str.append(node->TextRefFile().c_str());
    if (!node->TextRefFragmentId().empty())
    {
        str.append("#");
        str.append(node->TextRefFragmentId().c_str());
    }

    smilItem[@"textref"] = [NSString stringWithUTF8String: str.c_str()];

    smilItem[@"epubtype"] = [NSString stringWithUTF8String: node->Type().c_str()];

    NSMutableArray *children = [NSMutableArray array];

    auto count = node->GetChildrenCount();
    for (int i = 0; i < count; i++)
    {
        const ePub3::SMILData::TimeContainer *container = node->GetChild(i);

        //const ePub3::SMILData::Sequence *seq = dynamic_cast<ePub3::SMILData::Sequence *>(container);
        //if (seq != nullptr)
        //if ([[NSString stringWithUTF8String:container->Name().c_str()] isEqualToString:@"seq"])
        if (container->IsSequence())
        {
            NSMutableDictionary *seqx = [self parseTree_Sequence: (ePub3::SMILData::Sequence *)container];
            [children addObject:seqx];
            continue;
        }

        //const ePub3::SMILData::Parallel *par = dynamic_cast<ePub3::SMILData::Parallel *>(container);
        //if (par != nullptr)
        //if ([[NSString stringWithUTF8String: container->Name().c_str()] isEqualToString:@"par"])
        if (container->IsParallel())
        {
            NSMutableDictionary *parx = [self parseTree_Parallel: (ePub3::SMILData::Parallel *)container];
            [children addObject:parx];
            continue;
        }

        throw std::invalid_argument("WTF?");
    }

    if ([children count] != 0)
    {
        smilItem[@"children"] = children;
    }

    return smilItem;
}

- (NSDictionary *)toDictionary {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSMutableArray *smilDictionaries = [NSMutableArray array];
    for(LOXSmilModel *mo in _smilModels) {
        [smilDictionaries addObject:[mo toDictionary]];
    }

    [dict setObject:smilDictionaries forKey:@"smil_models"];

    [dict setObject:self.duration forKey:@"duration"];

    [dict setObject:self.narrator forKey:@"narrator"];

    [dict setObject:self.activeClass forKey:@"activeClass"];

    [dict setObject:self.playbackActiveClass forKey:@"playbackActiveClass"];

    return dict;
}

- (void)dealloc {
    for(LOXSmilModel *mo in _smilModels) {
        [mo release];
    }
    [_smilModels release];
    [super dealloc];
}
@end