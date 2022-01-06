#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSSpecifier ()
- (instancetype)initWithName:(NSString *)name
                      target:(id)target
                         set:(SEL)setter
                         get:(SEL)getter
                      detail:(Class)detailClass
                        cell:(NSInteger)cellType
                        edit:(Class)editClass;
@end

@interface MPAVRoute : NSObject
@end

@interface APGRootListController : PSListController
- (void)disableAllExcept:(NSString *)except forPreferences:(NSMutableDictionary *)preferences;
@end
