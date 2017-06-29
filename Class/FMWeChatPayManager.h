//
//  WeChatPayManager.h
//  qygt
//
//  Created by 周发明 on 17/4/11.
//  Copyright © 2017年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPayConstant.h"

@interface FMWeChatPayManager : NSObject

+ (void)payWechatWithPayID:(NSString *)payID body:(NSString *)body totalMoney:(NSString *)totalMoney payResultHandle:(void(^)(FMPayState state, NSString *errstring))handleBlock;

@end
