#import "FlutterDialpadPlugin.h"
#if __has_include(<flutter_dialpad/flutter_dialpad-Swift.h>)
#import <flutter_dialpad/flutter_dialpad-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_dialpad-Swift.h"
#endif

@implementation FlutterDialpadPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterDialpadPlugin registerWithRegistrar:registrar];
}
@end
