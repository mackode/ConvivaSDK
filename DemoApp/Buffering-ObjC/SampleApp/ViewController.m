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
    [NSThread sleepForTimeInterval:1.0];
    [self.videoAnalytics reportPlaybackMetric:CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE value:[NSNumber numberWithInt:CONVIVA_PLAYING]];
    
    [NSThread sleepForTimeInterval:1.0];
    [self reportSeekStartAndBuffering];
    
    [NSThread sleepForTimeInterval:1.0];
    [self.videoAnalytics reportPlaybackMetric:CIS_SSDK_PLAYBACK_METRIC_SEEK_ENDED value:[NSNumber numberWithDouble:10.0]];
    
    [NSThread sleepForTimeInterval:1.0];
    [self.videoAnalytics reportPlaybackMetric:CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE value:[NSNumber numberWithInt:CONVIVA_STOPPED]];
    
    [NSThread sleepForTimeInterval:1.0];
    [self cleanupSDK];
}

-(void)reportSeekStartAndBuffering {
    [self.videoAnalytics reportPlaybackMetric:CIS_SSDK_PLAYBACK_METRIC_SEEK_STARTED value:[NSNumber numberWithDouble:10.0]];
    [self.videoAnalytics reportPlaybackMetric:CIS_SSDK_PLAYBACK_METRIC_PLAYER_STATE value:[NSNumber numberWithInt:CONVIVA_BUFFERING]];
}

- (void)reportPlayerInfo {
    NSMutableDictionary *playerInfo = [[NSMutableDictionary alloc] init];
    playerInfo[CIS_SSDK_PLAYER_MODULE_NAME] = @"ModuleName";
    playerInfo[CIS_SSDK_PLAYER_MODULE_VERSION] = @"ModuleVersion";
    playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_NAME] = @"FrameworkVersion";
    playerInfo[CIS_SSDK_PLAYER_FRAMEWORK_VERSION] = @"FrameworkName";
    [self.videoAnalytics setPlayerInfo:playerInfo];
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

-(void)createVideoSession {
    if (self.analytics)  {
       self.videoAnalytics = [self.analytics createVideoAnalytics];
        [self.videoAnalytics reportPlaybackRequested:[self buildContentInfo]];
    }
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
