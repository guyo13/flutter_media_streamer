// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "FlutterMediaStreamerPlugin.h"
#if __has_include(<flutter_media_streamer/flutter_media_streamer-Swift.h>)
#import <flutter_media_streamer/flutter_media_streamer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_media_streamer-Swift.h"
#endif

@implementation FlutterMediaStreamerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMediaStreamerPlugin registerWithRegistrar:registrar];
}
@end
