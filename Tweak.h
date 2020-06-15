#include <objc/objc-runtime.h>
#import <Foundation/Foundation.h>
#import <libhdev/HUtilities/HDownloadMediaWithProgress.h>

#define PLIST_PATH "/var/mobile/Library/Preferences/com.haoict.twitchnoadspref.plist"
#define PREF_CHANGED_NOTIF "com.haoict.twitchnoadspref/PrefChanged"

@interface TWAccountManager : NSObject
@property(readonly, nonatomic) BOOL isTurbo;
@end

@interface AVPlayerItemPrivate : AVPlayerItem
- (NSURL *)_URL;
@end

@interface TwitchVideoPlayerView : UIView
@property(nonatomic, readonly) AVPlayerLayer *playerLayer;
- (void)addHandleLongPress; // new
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender; // new
@end