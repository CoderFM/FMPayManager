//
//  FMPayManager.m
//  qygt
//
//  Created by 周发明 on 17/4/12.
//  Copyright © 2017年 途购. All rights reserved.
//

#import "FMPayManagerTool.h"
#import "FMWeChatPayManager.h"
#import "FMAlipayManager.h"

@interface FMPayManagerTool ()

@property(nonatomic, assign)FMPayType curentPayType;
@property(nonatomic, copy)NSString *orderID;
@property(nonatomic, assign)NSString *totalMoney;

@property(nonatomic, assign)FMPayState payState;

@property(nonatomic, copy)NSString *message;

@property(nonatomic, copy)void(^handleResuleBlock)(FMPayState payState ,NSString *errString);

@end

@implementation FMPayManagerTool

+ (instancetype)shareManager{
    static FMPayManagerTool *_FMPayManagerToolInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _FMPayManagerToolInstance = [[self alloc] init];
    });
    return _FMPayManagerToolInstance;
}

- (void)payType:(FMPayType)type orderID:(NSString *)payID body:(NSString *)body totalMoney:(NSString *)totalMoney payResultHandle:(void(^)(FMPayState state, NSString *errstring))handleBlock{
    self.curentPayType = type;
    self.orderID = payID;
    self.totalMoney = totalMoney;
    self.payState = FMPayProceedState;
    self.handleResuleBlock = handleBlock;
    
    if (type == FMPayWeChatType) { // 微信支付
        [FMWeChatPayManager payWechatWithPayID:payID body:body totalMoney:[NSString stringWithFormat:@"%ld", (NSInteger)([totalMoney floatValue] * 100)] payResultHandle:handleBlock];
    } else { // 支付宝支付
        [FMAlipayManager payAlipayWithPayID:payID body:body totalMoney:[totalMoney floatValue]];
    }
}

- (BOOL)handlePayUrl:(NSURL *)url{
    BOOL result = [WXApi handleOpenURL:url delegate:self];
    if (result == FALSE) {
        if ([url.host isEqualToString:@"safepay"]) {
            result = YES;
            //跳转支付宝钱包进行支付，处理支付结果
            [self handleAlipayUrl:url];
        }
    }
    return result;
}

- (BOOL)handleAlipayUrl:(NSURL *)url{
    WeakSelf
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        if ([resultDic[@"resultStatus"] integerValue]== 9000) {
            weakSelf.payState = FMPaySuccessType;
        } else {
            weakSelf.payState = FMPayFailedType;
        }
        weakSelf.message = resultDic[@"memo"] ? : @"";
        [weakSelf returnLoad];
    }];
    return YES;
}

- (void)returnLoad {
    NSString *url = @"/tuanbi/alipaysuccess";
    NSArray *keys = @[@"logid", @"state", @"errormsg"];
    NSArray *values = @[self.orderID, @(self.payState), self.message];
    WeakSelf
    [[NetWorkingTool shareNetWorkingTool] requestWithModel:[NetRepuestModel initWithUrl:url keys:keys values:values] successBlock:^(NetReponseModel *model) {
        if (model.status == 1){
            if (weakSelf.handleResuleBlock) {
                weakSelf.handleResuleBlock(weakSelf.payState, weakSelf.message);
            }
        }
    }];
}

#pragma mark  -----  微信支付的代理
- (void)onReq:(BaseReq *)req{ // 收到微信的响应
    
}

- (void)onResp:(BaseResp *)resp{ // 收到微信的请求
    // WXSuccess           = 0,    /**< 成功    */
    // WXErrCodeCommon     = -1,   /**< 普通错误类型    */
    // WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    // WXErrCodeSentFail   = -3,   /**< 发送失败    */
    // WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
    // WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
    switch (resp.errCode) {
        case WXSuccess:
            self.payState = FMPaySuccessType;
            self.message = @"支付成功";
            break;
        case WXErrCodeUserCancel:
            self.payState = FMPayFailedType;
            self.message = @"用户点击取消并返回";
            break;
        default:
            self.payState = FMPayFailedType;
            self.message = @"支付失败";
            break;
    }
    [self returnLoad];
}

@end
