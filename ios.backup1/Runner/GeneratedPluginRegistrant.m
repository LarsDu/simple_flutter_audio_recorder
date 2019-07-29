//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <audio_recorder/AudioRecorderPlugin.h>
#import <audioplayers/AudioplayersPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <simple_permissions/SimplePermissionsPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AudioRecorderPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioRecorderPlugin"]];
  [AudioplayersPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioplayersPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [SimplePermissionsPlugin registerWithRegistrar:[registry registrarForPlugin:@"SimplePermissionsPlugin"]];
}

@end
