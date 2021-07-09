#include "APGRootListController.h"

@implementation APGRootListController

- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }

  MPAVRoute *route = [MPAVRoute new];

  if ([route respondsToSelector:@selector(isB298Route)]) {
    PSSpecifier *airpodsProSpecifier =
        [[PSSpecifier alloc] initWithName:@"Force AirPods Pro Glyph"
                                   target:self
                                      set:@selector(setPreferenceValue:specifier:)
                                      get:@selector(readPreferenceValue:)
                                   detail:nil
                                     cell:6
                                     edit:nil];
    airpodsProSpecifier.properties[@"default"] = @NO;
    airpodsProSpecifier.properties[@"defaults"] = @"com.level3tjg.airpodsglyph";
    airpodsProSpecifier.properties[@"key"] = @"forceAirpodsPro";
    [_specifiers addObject:airpodsProSpecifier];
  }

  if ([route respondsToSelector:@selector(isB515Route)]) {
    PSSpecifier *airpodsMaxSpecifier =
        [[PSSpecifier alloc] initWithName:@"Force AirPods Max Glyph"
                                   target:self
                                      set:@selector(setPreferenceValue:specifier:)
                                      get:@selector(readPreferenceValue:)
                                   detail:nil
                                     cell:6
                                     edit:nil];
    airpodsMaxSpecifier.properties[@"default"] = @NO;
    airpodsMaxSpecifier.properties[@"defaults"] = @"com.level3tjg.airpodsglyph";
    airpodsMaxSpecifier.properties[@"key"] = @"forceAirpodsMax";
    [_specifiers addObject:airpodsMaxSpecifier];
  }

  return _specifiers;
}

- (void)respring {
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                       CFSTR("respring"), NULL, NULL, false);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(respring)];
}

@end