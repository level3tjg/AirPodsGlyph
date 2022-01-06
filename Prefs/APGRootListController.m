#include "APGRootListController.h"

@implementation APGRootListController

- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }

  if ([MPAVRoute instancesRespondToSelector:@selector(isB298Route)]) {
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

  if ([MPAVRoute instancesRespondToSelector:@selector(isB515Route)]) {
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

  if ([MPAVRoute instancesRespondToSelector:@selector(isB688Route)]) {
    PSSpecifier *airpodsGen3Specifier =
        [[PSSpecifier alloc] initWithName:@"Force AirPods Gen 3 Glyph"
                                   target:self
                                      set:@selector(setPreferenceValue:specifier:)
                                      get:@selector(readPreferenceValue:)
                                   detail:nil
                                     cell:6
                                     edit:nil];
    airpodsGen3Specifier.properties[@"default"] = @NO;
    airpodsGen3Specifier.properties[@"defaults"] = @"com.level3tjg.airpodsglyph";
    airpodsGen3Specifier.properties[@"key"] = @"forceAirpodsGen3";
    [_specifiers addObject:airpodsGen3Specifier];
  }

  return _specifiers;
}

- (void)disableAllExcept:(NSString *)except forPreferences:(NSMutableDictionary *)preferences {
  for (PSSpecifier *specifier in _specifiers) {
    NSString *key = specifier.properties[@"key"];
    if (specifier.cellType == 6 && ![key isEqualToString:except]) {
      preferences[key] = @NO;
      UISwitch *control = specifier.properties[@"control"];
      [control setOn:NO animated:YES];
    }
  }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
  NSString *key = specifier.properties[@"key"];
  NSString *preferencesPath = [NSString
      stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSMutableDictionary *preferences =
      [NSMutableDictionary dictionaryWithContentsOfFile:preferencesPath];
  [self disableAllExcept:key forPreferences:preferences];
  preferences[key] = value;
  [preferences writeToFile:preferencesPath atomically:YES];

  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                       CFSTR("com.level3tjg.airpodsglyph/prefsChanged"), NULL, NULL,
                                       false);
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
  NSString *preferencesPath = [NSString
      stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:preferencesPath];
  return preferences[specifier.properties[@"key"]];
}

@end