#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSSpecifier (Private)
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

@end
