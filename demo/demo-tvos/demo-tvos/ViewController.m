//
//  ViewController.m
//  demo-tvos
//
//  Created by Single on 2018/11/5.
//  Copyright © 2018 Single. All rights reserved.
//

#import "ViewController.h"
#import <SGPlayer/SGPlayer.h>

@interface ViewController ()

@property (nonatomic, assign) BOOL seeking;
@property (nonatomic, strong) SGAsset *asset;
@property (nonatomic, strong) SGPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"i-see-fire" withExtension:@"mp4"];
    self.asset = [[SGURLAsset alloc] initWithURL:URL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(infoChanged:)
                                                 name:SGPlayerDidChangeInfosNotification
                                               object:self.player];
    
    self.player = [[SGPlayer alloc] init];
    self.player.videoRenderer.view = self.view;
    [self.player replaceWithAsset:self.asset];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([self.player waitUntilReady]) {
            [self.player play];
        }
    });
}

#pragma mark - SGPlayer Notifications

- (void)infoChanged:(NSNotification *)notification
{
    SGTimeInfo time = [SGPlayer timeInfoFromUserInfo:notification.userInfo];
    SGStateInfo state = [SGPlayer stateInfoFromUserInfo:notification.userInfo];
    SGInfoAction action = [SGPlayer infoActionFromUserInfo:notification.userInfo];
    if (action & SGInfoActionTime) {
        NSLog(@"playback: %f, duration: %f, cached: %f",
              CMTimeGetSeconds(time.playback),
              CMTimeGetSeconds(time.duration),
              CMTimeGetSeconds(time.cached));
    }
    if (action & SGInfoActionState) {
        NSLog(@"player: %d, loading: %d, playback: %d, playing: %d, seeking: %d, finished: %d",
              state.player, state.loading, state.playback,
              state.playback & SGPlaybackStatePlaying,
              state.playback & SGPlaybackStateSeeking,
              state.playback & SGPlaybackStateFinished);
    }
}

@end
