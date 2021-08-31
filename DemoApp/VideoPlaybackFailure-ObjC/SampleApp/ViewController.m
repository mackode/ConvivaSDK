//
//  ViewController.m
//  SampleTestApp
//
//  Created by Nirvaid Rathore on 10/03/16.
//  Copyright © 2016 Nirvaid Rathore. All rights reserved.
//

#import "ViewController.h"
#import "XYZPlayerInterface.h"
#import "XYZPlayer.h"

@interface ViewController ()

@property(nonatomic,strong) CISAnalytics analytics;
@property(nonatomic,strong) CISVideoAnalytics videoAnalytics;

@property(nonatomic,strong) XYZPlayerInterface *xyzVideoPlayerInterface;
@property(nonatomic,strong) XYZPlayer *xyzVideoPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)initSDKClicked:(id)sender {
    NSDictionary *settings = @{
        CIS_SSDK_SETTINGS_GATEWAY_URL: @"AAA",
        CIS_SSDK_SETTINGS_LOG_LEVEL: @(LOGLEVEL_WARNING)
    };
    self.analytics =  [CISAnalyticsCreator createWithCustomerKey:@"BBB" settings:settings];
    
    [self createVideoSession];
    [self reportPlayerInfo];
    /// Video Start Failure
    /// NOTE: no delay causes `Exit before video start`
//    [NSThread sleepForTimeInterval:5.0]; /// NOTE: 5 seconds delay makes FrameworkName and Version is not reported
//    [NSThread sleepForTimeInterval:10.0]; /// NOTE:  10 seconds delay makes everything reported correctly
    [self reportError];
    [self cleanupSDK];
}

- (void)reportError {
    NSMutableDictionary *contentInfo = [[NSMutableDictionary alloc] init];
    contentInfo[@"errorId"] = @"Video start error";

    [self.videoAnalytics reportPlaybackFailed:@"Video start failure" contentInfo:contentInfo];
}

-(NSDictionary *)buildContentInfo {
    NSDictionary *contentInfo = @{  CIS_SSDK_METADATA_ASSET_NAME:@"asset",
                                    CIS_SSDK_METADATA_IS_LIVE:@(true),
                                    CIS_SSDK_METADATA_PLAYER_NAME:@"playername",
                                    CIS_SSDK_METADATA_VIEWER_ID:@"viewerid",
                                    CIS_SSDK_METADATA_DEFAULT_RESOURCE:@"resource",
                                    CIS_SSDK_METADATA_DURATION:@(100),
                                    CIS_SSDK_METADATA_STREAM_URL:@"http://test.m3u8",
                                    CIS_SSDK_PLAYER_FRAMEWORK_NAME:@"frameworkname",
                                    CIS_SSDK_PLAYER_FRAMEWORK_VERSION:@"frameworkversion",
                                    @"tags":@{@"key1":@"val1",@"key2":@"val2"}
                                    };

    return contentInfo;
}

- (void)updateMetaData {
    NSDictionary *contentInfo = @{
                                       CIS_SSDK_METADATA_IS_LIVE:@(true),
                                       CIS_SSDK_METADATA_PLAYER_NAME:@"playername",
                                       CIS_SSDK_METADATA_VIEWER_ID:@"viewerid",
                                       CIS_SSDK_METADATA_DEFAULT_RESOURCE:@"LEVEL3",
                                       CIS_SSDK_METADATA_DURATION:@(100),
                                       CIS_SSDK_METADATA_STREAM_URL:@"http://test.m3u8"
                                       };
 
    [self.videoAnalytics setContentInfo:contentInfo];
}

-(void)createVideoSession {
    if (self.analytics)  {
       self.videoAnalytics = [self.analytics createVideoAnalytics];
        [self.videoAnalytics reportPlaybackRequested:[self buildContentInfo]];
    }
}

- (void)reportPlayerInfo {
    NSMutableDictionary *playerInfo = [[NSMutableDictionary alloc] init];
    playerInfo[CIS_SSDK_PLAYER_MODULE_NAME] = @"ModuleName";
    playerInfo[CIS_SSDK_PLAYER_MODULE_VERSION] = @"ModuleVersion";
    playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = @"FrameworkVersion";
    playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = @"FrameworkName";
    [self.videoAnalytics setPlayerInfo:playerInfo];
}

- (void)cleanupSession {
    [self.videoAnalytics reportPlaybackEnded];
    [self.videoAnalytics cleanup];
    self.videoAnalytics = nil;
}

- (void)cleanupSDK {
    [self cleanupSession];
    
    [self.videoAnalytics cleanup];
    self.videoAnalytics = nil;
    
    [self.analytics cleanup];
    self.analytics = nil;
}

@end
