//
//  FMPayManager.h
//  qygt
//
//  Created by 周发明 on 17/4/12.
//  Copyright © 2017年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPayConstant.h"

#define FMPayManager [FMPayManagerTool shareManager]

@interface FMPayManagerTool : NSObject<WXApiDelegate>

+ (instancetype)shareManager;
/**
 调用支付

 @param type 支付方式   支付宝还是微信
 @param payID 服务端生成的订单号
 @param body 支付时要显示的标题
 @param totalMoney 总金额  单位/元
 */
- (void)payType:(FMPayType)type orderID:(NSString *)payID body:(NSString *)body totalMoney:(NSString *)totalMoney payResultHandle:(void(^)(FMPayState state, NSString *errString))handleBlock;

- (BOOL)handlePayUrl:(NSURL *)url;

@end
