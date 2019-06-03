//
//  ViewController.m
//  五子棋-天梯（pvp）
//
//  Created by 国梁李 on 2019/5/27.
//  Copyright © 2019 国梁李. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
BOOL _gameCenterEnabled;
NSString *_leaderboardIdentifier = @"1001";

#pragma mark leaderboard
- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(NSViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewControllerAsSheet:viewController];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
             //   _gameCenterEnabled = YES;
                NSLog(@"authenticated");
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    NSLog(@"%@", leaderboardIdentifier);
                    if (error != nil) {
                        NSLog(@"here");
                        NSLog(@"%@", [error description]);
                    }
                    else{
                      //  _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
                
            }
            
            else{
             //   _gameCenterEnabled = NO;
            }
        }
    };
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self authenticateLocalPlayer];
  
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(NSViewController *)gameCenterLoginController {
    NSLog(@"Attempting to present login controller");
    [self presentViewControllerAsModalWindow:gameCenterLoginController];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availability: %@", availabilityInformation);
    if ([availabilityInformation objectForKey:@"message"] != nil) {
        self.detailedStatus.stringValue = [availabilityInformation objectForKey:@"message"];
    }
    
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
        self.gameCenterStatus.stringValue = @"GAME CENTER AVAILABLE";
        self.detailedStatus.stringValue = @"Game Center is online, the current player is logged in, and this app is setup.";
    } else {
        self.gameCenterStatus.stringValue = @"GAME CENTER UNAVAILABLE";
        self.detailedStatus.stringValue = [availabilityInformation objectForKey:@"message"];
    }
    
    // Get Player Status
    GKLocalPlayer *player = [[GameCenterManager sharedManager] localPlayerData];
    if (player) {
        if ([player isUnderage] == NO) {
            self.actionStatus.stringValue = [NSString stringWithFormat:@"%@ signed in.", player.displayName];
            self.playerName.stringValue = player.displayName;
            self.playerStatus.stringValue = @"Player is not underage and is signed in";
            [[GameCenterManager sharedManager] localPlayerPhoto:^(NSImage *playerPhoto) {
                self.playerProfilePicture.image = playerPhoto;
                self.playerProfilePicture.layer.cornerRadius = self.playerProfilePicture.bounds.size.width/2;
                [self.playerProfilePicture setNeedsDisplay];
            }];
        } else {
            self.actionStatus.stringValue = [NSString stringWithFormat:@"Underage player, %@, signed in.", player.displayName];
        }
    } else {
        self.actionStatus.stringValue = [NSString stringWithFormat:@"No GameCenter player found."];
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GC Error: %@", error);
    if (error.code == GCMErrorAchievementDataMissing) {
        self.detailedStatus.stringValue = [NSString stringWithFormat:@"Could not save achievement. Data missing."];
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
        self.actionStatus.stringValue = [NSString stringWithFormat:@"Reported achievement with %.1f percent completed", achievement.percentComplete];
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
        self.actionStatus.stringValue = [NSString stringWithFormat:@"Reported leaderboard score: %lld", score.value];
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
    self.actionStatus.stringValue = [NSString stringWithFormat:@"Score saved for upload to GameCenter."];
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
    self.actionStatus.stringValue = [NSString stringWithFormat:@"Achievement saved for upload to GameCenter."];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewController:gameCenterViewController];
    self.actionStatus.stringValue = [NSString stringWithFormat:@"Displayed GameCenter leaderboard."];
}

- (IBAction)submitHighscore:(id)sender {
    [[GameCenterManager sharedManager] saveAndReportScore:[[GameCenterManager sharedManager] highScoreForLeaderboard:@"grp.PlayerScores"]+1 leaderboard:@"grp.PlayerScores" sortOrder:GameCenterSortOrderHighToLow];
    [self.actionStatus setStringValue:[NSString stringWithFormat:@"Score recorded."]];
}

- (IBAction)submitAchievement:(id)sender {
    if ([[GameCenterManager sharedManager] progressForAchievement:@"grp.FirstAchievement"] == 100) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"grp.SecondAchievement" percentComplete:100 shouldDisplayNotification:YES];
    }
    
    if ([[GameCenterManager sharedManager] progressForAchievement:@"grp.FirstAchievement"] == 0) {
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"grp.FirstAchievement" percentComplete:100 shouldDisplayNotification:YES];
        [[GameCenterManager sharedManager] saveAndReportAchievement:@"grp.SecondAchievement" percentComplete:50 shouldDisplayNotification:NO];
    }
    
    NSLog(@"Achievement One Progress: %f | Achievement Two Progress: %f", [[GameCenterManager sharedManager] progressForAchievement:@"grp.FirstAchievement"], [[GameCenterManager sharedManager] progressForAchievement:@"grp.SecondAchievement"]);
    [self.actionStatus setStringValue:[NSString stringWithFormat:@"Achievement recorded."]];
}

- (IBAction)resetAchievements:(id)sender {
    [[GameCenterManager sharedManager] resetAchievementsWithCompletion:^(NSError *error) {
        if (error) {
            self.actionStatus.stringValue = [NSString stringWithFormat:@"Error reseting all GameCenter achievements."];
        } else {
            self.actionStatus.stringValue = [NSString stringWithFormat:@"Reset all GameCenter achievements."];
        }
    }];
}

- (IBAction)openLeaderboards:(id)sender {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    [self presentViewControllerAsSheet:mmvc];
}

- (IBAction)openAchievements:(id)sender {
    GKGameCenterViewController *achievementViewController = [[GKGameCenterViewController alloc] init];
    achievementViewController.viewState = GKGameCenterViewControllerStateAchievements;
    achievementViewController.gameCenterDelegate = self;
    [self presentViewControllerAsModalWindow:achievementViewController];
    self.actionStatus.stringValue = [NSString stringWithFormat:@"Attempting to display GameCenter achievements."];
    NSLog(@"Attempting to display GameCenter achievements.");
}

- (IBAction)fetchChallenges:(id)sender {
    // This feature is only supported in OS X 10.8.2 and higher
    [[GameCenterManager sharedManager] getChallengesWithCompletion:^(NSArray *challenges, NSError *error) {
        self.actionStatus.stringValue = [NSString stringWithFormat:@"Loaded GameCenter challenges."];
        NSLog(@"GC Challenges: %@", challenges);
    }];
}


@end
