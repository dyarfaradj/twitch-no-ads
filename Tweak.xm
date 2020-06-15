#import "Tweak.h"

/**
 * Load Preferences
 */
BOOL noads;
BOOL canSaveMedia;

static void reloadPrefs() {
  NSDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH] ?: [@{} mutableCopy];

  noads = [[settings objectForKey:@"noads"] ?: @(YES) boolValue];
  canSaveMedia = [[settings objectForKey:@"canSaveMedia"] ?: @(YES) boolValue];
}

%group NoAds
  %hook TWAccountManager
    - (BOOL)isTurbo {
      return TRUE;
    }
  %end
%end

// %hook TwitchTheaterView
//   - (void)viewDidAppear:(BOOL)arg1 {
//     Ivar videoMetadataIvar = class_getInstanceVariable([self class], "videoMetadata");
//     id videoMetadata = object_getIvar(self, videoMetadataIvar);
//     Ivar videoIvar = class_getInstanceVariable([videoMetadata class], "video");
//     id video = object_getIvar(videoMetadata, videoIvar);
//     return;
//   }
// %end

%group SwiftGroup
  %hook TwitchVideoPlayerView
    - (void)didMoveToWindow {
      %orig;
      TwitchVideoPlayerView *temp = self;
      [temp addHandleLongPress];
    }

     %new
    - (void)addHandleLongPress {
      UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
      longPress.minimumPressDuration = 0.5;
      [self addGestureRecognizer:longPress];
    }

    %new
    - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
      if (sender.state == UIGestureRecognizerStateBegan) {
        TwitchVideoPlayerView *temp = self;
        NSURL *videoURL = nil;
        @try {
          videoURL = [((AVPlayerItemPrivate *)[temp.playerLayer.player currentItem]) _URL];
          if (!videoURL) {
            [HCommon showAlertMessage:@"Can't find video URL to download" withTitle:@"Error" viewController:nil];
            return;
          } else if ([videoURL.absoluteString containsString:@".m3u8"]) {
            [HCommon showAlertMessage:@"Download live/stream video (.m3u8) is currently not supported due to limitation of iOS. Stay tuned for the next update. For now you can only download clips." withTitle:@"Not supported" viewController:nil];
            return;
          }
        } @catch (NSError *error) {}

        __block UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        topWindow.rootViewController = [UIViewController new];
        topWindow.windowLevel = UIWindowLevelAlert + 1;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Download video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          [[[HDownloadMediaWithProgress alloc] init] checkPermissionToPhotosAndDownloadURL:videoURL appendExtension:nil mediaType:Video toAlbum:@"Twitch" view:temp];
          topWindow.hidden = YES;
          topWindow = nil;
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
          topWindow.hidden = YES;
          topWindow = nil;
        }]];
        [topWindow makeKeyAndVisible];
        [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
      }
    }
  %end
%end

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  reloadPrefs();

  // NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  // if ([version compare:@"9.2" options:NSNumericSearch] == NSOrderedAscending) {
  //   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
  //     dispatch_async(dispatch_get_main_queue(), ^{
  //       [HCommon showAlertMessage:@"Your current version of Twitch is not supported, please go to App Store and update it (>=9.2)" withTitle:@"Please update Twitch" viewController:nil];
  //     });
  //   });
  // }

  if (noads) {
    %init(NoAds);
  }

  if (canSaveMedia) {
    // %init(TwitchTheaterView = objc_getClass("Twitch.TheaterViewController"));
    %init(SwiftGroup, TwitchVideoPlayerView = objc_getClass("Twitch.VideoPlayerView"));
  }
}
