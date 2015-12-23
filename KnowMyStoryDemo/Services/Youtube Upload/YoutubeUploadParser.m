//
//  YoutubeUploadParser.m
//  KnowMyStoryDemo
//
//  Created by Fingent on 28/01/15.
//  Copyright (c) 2015 Fingent. All rights reserved.
//

#import "YoutubeUploadParser.h"
#import "WizardViewController.h"

@implementation YoutubeUploadParser
-(id)parseUploadResponse:(id)response{
    id resultInfo =[self parseResponse:response];
    
    WizardViewController *wizardVC = [WizardViewController sharedInstance];
    if([resultInfo isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *youtubeResponse = (NSDictionary *)resultInfo;
         if([youtubeResponse objectForKey:@"youtube_id"]&& ![[youtubeResponse objectForKey:@"youtube_id"]isEqual:[NSNull null]]&&[youtubeResponse objectForKey:@"youtube_id"]!=nil){
             
             [wizardVC.currentProjectDict setValue:[youtubeResponse objectForKey:@"youtube_id"] forKey:@"YoutubeId"];
         }
           if([youtubeResponse objectForKey:@"scripture_text"]&& ![[youtubeResponse objectForKey:@"scripture_text"]isEqual:[NSNull null]]&&[youtubeResponse objectForKey:@"scripture_text"]!=nil){
               
        [wizardVC.currentProjectDict setValue:[youtubeResponse objectForKey:@"scripture_text"]
                                       forKey:@"ScriptureText"];
           }
           if([youtubeResponse objectForKey:@"title"]&& ![[youtubeResponse objectForKey:@"title"]isEqual:[NSNull null]]&&[youtubeResponse objectForKey:@"title"]!=nil){
               
        [wizardVC.currentProjectDict setValue:[youtubeResponse objectForKey:@"title"] forKey:@"Title"];
           }
           if([youtubeResponse objectForKey:@"description"]&& ![[youtubeResponse objectForKey:@"description"]isEqual:[NSNull null]]&&[youtubeResponse objectForKey:@"description"]!=nil){
               
         [wizardVC.currentProjectDict setValue:[youtubeResponse objectForKey:@"description"] forKey:@"Description"];
           }
           if([youtubeResponse objectForKey:@"video_id"]&& ![[youtubeResponse objectForKey:@"video_id"]isEqual:[NSNull null]]&&[youtubeResponse objectForKey:@"video_id"]!=nil){
               
          [wizardVC.currentProjectDict setValue:[youtubeResponse objectForKey:@"video_id"] forKey:@"VideoId"];
           }
        [wizardVC saveProjectData];
        
    }
    return resultInfo;
}
@end
