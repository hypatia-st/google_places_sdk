#import "GooglePlacesSdkPlugin.h"
#if __has_include(<google_places_sdk/google_places_sdk-Swift.h>)
#import <google_places_sdk/google_places_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "google_places_sdk-Swift.h"
#endif

@implementation GooglePlacesSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGooglePlacesSdkPlugin registerWithRegistrar:registrar];
}
@end
