//
//  FMAlipayManager.h
//  qygt
//
//  Created by 周发明 on 17/4/12.
//  Copyright © 2017年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMAlipayManager : NSObject

+ (void)payAlipayWithPayID:(NSString *)payID body:(NSString *)body totalMoney:(double)totalMoney;

@end
