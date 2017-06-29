//
//  FMPayConstant.h
//  qygt
//
//  Created by 周发明 on 17/4/12.
//  Copyright © 2017年 途购. All rights reserved.
//

#ifndef FMPayConstant_h
#define FMPayConstant_h

#import <AlipaySDK/AlipaySDK.h>     // 导入AlipaySDK
//#import "AlipayRequestConfig.h"     // 导入支付类
#import "Order.h"                   // 导入订单类
#import "DataSigner.h"              // 生成signer的类：获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循 RSA 签名规范, 并将签名字符串 base64 编码和 UrlEncode

#import <Foundation/Foundation.h>   // 导入Foundation，防止某些类出现类似：“Cannot find interface declaration for 'NSObject', superclass of 'Base64'”的错误提示

#import "FMEquipmentTool.h"
#import "WXApi.h"

#pragma mark ------  公用常量

typedef NS_ENUM(NSInteger ,FMPayType){
    FMPayWeChatType = 1,// 微信支付
    FMPayAlipayType = 2 // 支付宝支付
};

typedef NS_ENUM(NSInteger ,FMPayState){
    FMPayProceedState = -1, // 支付进行中
    FMPayFailedType = 0, // 支付失败
    FMPaySuccessType = 1, // 支付成功
};

static NSString *const PayDefaultBody = @"蜂优客-团币充值";


#pragma mark ------  支付宝常量
static NSString * const AlipayPayAsyncNotifyURL = @"http://agent.quygt.com/alipay/alipaynotify";
/**
 *  partner:合作身份者ID,以 2088 开头由 16 位纯数字组成的字符串。
 *
 */
static NSString * const AlipayPartnerID = @"2016080901724287";

/**
 *  seller:支付宝收款账号,手机号码或邮箱格式。
 */
static NSString * const AlipaySeller = @"zhouleijian@quygt.com";

/**
 *  appSckeme:应用注册scheme,在Info.plist定义URLtypes，处理支付宝回调
 */
static NSString * const AlipayAppScheme = @"liXinYuAlipay";

/**
 *  private_key:商户方的私钥,pkcs8 格式。
 */

#define kPrivateKey @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANYlUM+Iv46plRjBOOZ5MCdpQDLorjrBH7GNpqjMGLYryyON4eIY+AYD+JMTAlAIFxOzon2AJF5HeRnyA4XTXJmw96yM2EOJXjOW+w6ocnGWACDQTH4rn1vgjvUlVF6T3D31oylTwoS/37xD    g9TkxbSbmI4axHPJUP6c2WhwuNGlAgMBAAECgYEAj1dTDFfgwUHKR1OvHraoAPl2u5z8Yt+6s0K59+sF74rI4vep54oHGx+1V901gxSnPczUS2Vm8qSs7y0MJpwgMpZK    hjXsAI31sRqzbpbWNWBFuWaajCtTttzsGhgA8B9tbsc2Hjjm7UC7YSPlEn0jWwQoVnd+SO692rI2cjxGmIECQQD3vRy89JsHmEHEPUEqUgl7CBIexKthWVIQlbf7PNpW/lnjOClOkMfrUhlHPfFxs7tDj5msnXLQfwKDW+aNqCFJAkEA3UltnMF4UOdag193k/59B4GhPMU41W6eXKqaWRwdRU7JdRsc4K30hzESW6N6oKvTQFiJzTMdv2F81aBP    Dc0JfQJAbxVC748WfJ9OzflRYPKMAbiqt1UkK3BrlbgsWOD+XgeKspGaI/pTSjbz0rf5rSwUCcU3+OhYdRiePdxVUqtS0QJBAKKuPLslMIKp0s0J/ir6yIggMJ0wkJu3+ww9D8O6+3ncdhZ1nEFBIafR16EvChPcvi1r6cLFdXUhAlk6xWNr/TECQQDj2HZYrGeGo1xy/BvC1E4xrjyIb6mrXsWKug1swVxFsiD578U67nJNbFgDOgURUlI4vVRKrLXzcnLcbSp0rf5i"

#pragma mark ------  微信常量
// 回调通知
static NSString * const WeChatPayAsyncNotifyURL = @"http://agent.quygt.com/tenpay/tenpaynotify";   // 正式的
//static NSString * const WeChatPayAsyncNotifyURL = @"http://lvgounet.oicp.net:24561/tenpay/tenpaynotify"; // 测试的

static NSString *WeChatAppId = @"wx384a0e20d6d4b6bd"; //应用ID
static NSString *WeChatPartnerId = @"1318307201"; // 商户ID
static NSString *WeChatAppKey = @"lkjoIJDF09239jfPFUsdf33j002390gm"; //秘钥

#endif /* FMPayConstant_h */
