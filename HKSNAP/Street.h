//
//  Street.h
//  HKSNAP
//
//  Created by xinweizhou on 2022/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Street : NSObject

@property(nonatomic, strong) NSString *name;

- (NSInteger) getNumOfPeople;

@end

NS_ASSUME_NONNULL_END
