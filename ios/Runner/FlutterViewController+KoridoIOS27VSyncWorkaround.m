#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static BOOL KoridoShouldDisableIOS27FlutterTouchRateCorrection(void) {
  NSOperatingSystemVersion version = NSProcessInfo.processInfo.operatingSystemVersion;
  return version.majorVersion >= 27;
}

@implementation FlutterViewController (KoridoIOS27VSyncWorkaround)

+ (void)load {
  if (!KoridoShouldDisableIOS27FlutterTouchRateCorrection()) {
    return;
  }

  SEL originalSelector = NSSelectorFromString(@"createTouchRateCorrectionVSyncClientIfNeeded");
  SEL replacementSelector = @selector(korido_disableIOS27TouchRateCorrection);

  Method originalMethod = class_getInstanceMethod(self, originalSelector);
  Method replacementMethod = class_getInstanceMethod(self, replacementSelector);
  if (originalMethod == NULL || replacementMethod == NULL) {
    return;
  }

  method_exchangeImplementations(originalMethod, replacementMethod);
}

- (void)korido_disableIOS27TouchRateCorrection {
  // iOS 27 beta crashes in Flutter 3.44.2's touch-rate VSyncClient before Dart starts.
  // Rendering vsync remains active; only the high-refresh touch correction hook is skipped.
}

@end
