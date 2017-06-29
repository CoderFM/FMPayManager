//
//  WeChatPayManager.m
//  qygt
//
//  Created by 周发明 on 17/4/11.
//  Copyright © 2017年 途购. All rights reserved.
//

#import "FMWeChatPayManager.h"

@interface FMXMLParser : NSObject<NSXMLParserDelegate>

@property(nonatomic, strong)NSData *xmlData;

@property(nonatomic, strong)NSXMLParser *xmlParser;

@property(nonatomic, strong)NSMutableDictionary *resultDict;

@property(nonatomic, copy)void(^successBlock)(NSString *errorString, NSDictionary *result);

@property(nonatomic, strong)NSMutableString *contentString;

@end

@implementation FMXMLParser

- (instancetype)initWithData:(NSData *)data successBlock:(void(^)(NSString *errorString, NSDictionary *result))successBlock{
    if (self = [super init]) {
        self.xmlParser = [[NSXMLParser alloc] initWithData:data];
        self.xmlParser.delegate = self;
        self.successBlock = successBlock;
    }
    return self;
}

- (void)startParser{
    if ([self.xmlParser parse]) {
        
    } else {
        if (self.successBlock) {
            self.successBlock(@"xml数据解析失败", nil);
        }
    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    self.resultDict = [NSMutableDictionary dictionary];
    self.contentString = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (![string isEqualToString:@"\n"]) {
        [self.contentString setString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (self.contentString && ![self.contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"] && ![elementName isEqualToString:@"xml"]) {
        [self.resultDict setObject:[self.contentString copy] forKey:elementName];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    if (self.successBlock) {
        self.successBlock(nil, self.resultDict);
    }
}

- (NSMutableDictionary *)resultDict{
    if (_resultDict == nil) {
        _resultDict = [NSMutableDictionary dictionary];
    }
    return _resultDict;
}

@end

@implementation FMWeChatPayManager

+ (void)payWechatWithPayID:(NSString *)payID body:(NSString *)body totalMoney:(NSString *)totalMoney payResultHandle:(void(^)(FMPayState state, NSString *errstring))handleBlock{
    [self payWechatCurrnetIP:@"127.0.0.1" payID:payID body:body totalMoney:[totalMoney integerValue]  payResultHandle:handleBlock];
}

+ (void)payWechatCurrnetIP:(NSString *)IP payID:(NSString *)payID body:(NSString *)body totalMoney:(NSInteger)totalMoney payResultHandle:(void(^)(FMPayState state, NSString *errstring))handleBlock{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:WeChatAppId forKey:@"appid"];
    [dict setObject:WeChatPartnerId forKey:@"mch_id"];
    NSString *time = [self nonce_strTimeString];
    [dict setObject:time forKey:@"nonce_str"];
    [dict setObject:body?:PayDefaultBody forKey:@"body"];
    [dict setObject:payID forKey:@"out_trade_no"];
    [dict setObject:[NSString stringWithFormat:@"%ld", (long)totalMoney] forKey:@"total_fee"];
    [dict setObject:IP forKey:@"spbill_create_ip"];
    [dict setObject:WeChatPayAsyncNotifyURL forKey:@"notify_url"];
    [dict setObject:@"APP" forKey:@"trade_type"];
    [dict setObject:[self getSignWithDict:dict] forKey:@"sign"];
    NSMutableString *xmlString = [NSMutableString string];
    [xmlString appendFormat:@"<xml>"];
    NSArray *allKeys = [dict allKeys];
    for (NSString *key in allKeys) {
        [xmlString appendFormat:@"<%@>%@</%@>", key , dict[key], key];
    }
    [xmlString appendFormat:@"</xml>"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mch.weixin.qq.com/pay/unifiedorder"]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[[FMXMLParser alloc] initWithData:data successBlock:^(NSString *errorString, NSDictionary *result) {
            if (!errorString) {
                if (result[@"prepay_id"]) {
                    [self turnWeChatPayWithPrePayID:result[@"prepay_id"] payResultHandle:handleBlock];
                } else{
                    if (handleBlock) {
                        handleBlock(FMPayFailedType, [NSString stringWithFormat:@"%@%@", errorString, result[@"return_msg"]]);
                    }
                }
            } else {
                if (handleBlock) {
                    handleBlock(FMPayFailedType, [NSString stringWithFormat:@"%@%@", errorString, result[@"return_msg"]]);
                }
            }
        }] startParser];
    }];
    [task resume];
}

+ (void)turnWeChatPayWithPrePayID:(NSString *)ID payResultHandle:(void(^)(FMPayState state, NSString *errstring))handleBlock{
    time_t now;
    time(&now);
    NSString *timeString = [NSString stringWithFormat:@"%ld", now];
    NSString *nonceStr = [Utility md5:timeString];
    
    NSDictionary *dict = @{@"appid" : WeChatAppId,
                           @"partnerid" : WeChatPartnerId,
                           @"prepayid":ID,
                           @"package":@"Sign=WXPay",
                           @"noncestr":nonceStr,
                           @"timestamp":timeString};
    
    PayReq *req = [[PayReq alloc] init];
    req.openID = WeChatAppId;
    req.partnerId = WeChatPartnerId;
    req.prepayId = ID;
    req.nonceStr = nonceStr;
    req.timeStamp = timeString.intValue;
    req.package = @"Sign=WXPay";
    req.sign = [self getSignWithDict:dict];
    if ([WXApi sendReq:req]){
        
    } else {
        if (handleBlock) {
            handleBlock(FMPayFailedType, @"支付失败");
        }
    }
}

+ (NSString *)nonce_strTimeString{
    time_t now;
    time(&now);
    return [NSString stringWithFormat:@"%ld", now];
}

+ (NSString *)getSignWithDict:(NSDictionary *)dict{
    NSMutableString *string = [NSMutableString string];
    NSArray *keys = [dict allKeys];
    NSArray *sortKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryID in sortKeys) {
        if (![[dict objectForKey:categoryID] isEqualToString:@""] && ![categoryID isEqualToString:@"sign"] && ![categoryID isEqualToString:@"key"]) {
            [string appendFormat:@"%@=%@&", categoryID, dict[categoryID]];
        }
    }
    [string appendFormat:@"key=%@", WeChatAppKey];
    return [[Utility md5:string] uppercaseString];
}

@end
