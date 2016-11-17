//
//  IGBaseNetwork.m
//
//
//  Created by ihealth-wyc on 16/8/11.
//  Copyright © 2016年 ihealth-wyc. All rights reserved.
//

#ifdef DEBUG
#define IGLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define IGLog(...)
#endif


#import "IGBaseNetwork.h"

#import <AFNetworking/AFNetworking.h>

#define GET_TOKEN @"/token/getToken"
#define LOCAL_TOKEN @"LOCAL_TOKEN"


@interface IGBaseNetwork()

@property (nonatomic,copy) NSString * baseURL;
@property (nonatomic,strong)AFHTTPSessionManager *manager;

@end


@implementation IGBaseNetwork

static IGBaseNetwork *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)IGBaseNetworkManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (void)setUpBaseURL:(NSString *)baseURL{
    
    _baseURL = baseURL;

}

- (void)POSTRequestWithUrlString:(NSString *)urlString parameter:(NSDictionary *)parameter accessTokenIfNeed:(BOOL)need success:(success)successBlock fail:(getFail)failBlock{

    if (need) {

        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:parameter];
        
        if ([self getLocalToken]) {
            
            [dict setValue:[self getLocalToken] forKey:@"AccessToken"];
            
            [self POSTRequestWithUrlString:urlString parameter:dict success:^(id responseTask) {
                
                 NSDictionary *  response = responseTask;
                
                if ([response[@"ResultMessage"] isEqualToString:@"221"]) {
                    
                    [self getAccessTokenWithSuccess:^(id responseTask) {
                        
                        [dict setValue:[self getLocalToken] forKey:@"AccessToken"];
                        
                        [self POSTRequestWithUrlString:urlString parameter:dict success:successBlock fail:failBlock];

                    } withFail:failBlock];
                    
                }else{
                
                    if (successBlock) {
                        
                        successBlock(responseTask);
                    }
                }
                
            } fail:^(NSInteger status, NSInteger resultMessage) {
                
                failBlock(status,resultMessage);
            }];
            
        }else{
        
            
            [self getAccessTokenWithSuccess:^(id responseTask) {
                
                [dict setValue:[self getLocalToken] forKey:@"AccessToken"];
                
                [self POSTRequestWithUrlString:urlString parameter:dict success:successBlock fail:failBlock];
                
            } withFail:failBlock];
            
        }
        
    }else{
        
        [self POSTRequestWithUrlString:urlString parameter:parameter success:successBlock fail:failBlock];
    }
}

- (void)POSTRequestWithUrlString:(NSString *)urlString parameter:(NSDictionary *)parameter  success:(success)successBlock fail:(getFail)failBlock{

    NSString * URL = [_baseURL stringByAppendingString:urlString];
    
    [self.manager POST:URL parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * response = responseObject;
        NSString * msg = @"";
        if (![response[@"ResultMessage"] isEqualToString:@"100"]) {
        
            msg =[NSString stringWithFormat:@" (ง •̀_•́)ง %@接口发生外部错误，错误码%@  (｡˘•ε•˘｡) ",URL,response[@"ResultMessage"]];
        }else{
            msg =[NSString stringWithFormat:@"(•̀ᴗ•́)و ̑̑%@接口调用成功，恭喜您,其返回内容为%@ (｡˘•ε•˘｡) ",URL,response];
        }

        IGLog(@"%@",msg);
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSString * msg =[NSString stringWithFormat:@" (ง •̀_•́)ง %@接口发生外部错误，错误码%ld  (｡˘•ε•˘｡)  ",URL,(long)response.statusCode];
        IGLog(@"%@",msg);
        failBlock((long)response.statusCode,(long)response.statusCode);
    }];

}

- (void)getAccessTokenWithSuccess:(success)success withFail:(getFail)fail {

    [self POSTRequestWithUrlString:GET_TOKEN parameter:@{@"AppVersion":[self getAppVersion]} success:^(id responseTask) {
        
        NSDictionary * response = responseTask;
        IGLog(@"%@",response);
        
        if ([response[@"ResultMessage"] isEqualToString:@"223"]) {
            NSString * msg =[NSString stringWithFormat:@" (ง •̀_•́)ง AppVersion不正确 ,请检查(｡˘•ε•˘｡)  "];
            IGLog(@"%@",msg);
        }
        
        NSString * token = response[@"ReturnValue"][0][@"AccessToken"];
        [self saveLocalToken:token];
        
        if (success) {
            success(responseTask);
        }

    } fail:fail];
}

- (NSString *)getAppVersion{
   
    return @"123";
//    return [[NSBundle mainBundle] bundleIdentifier];
}

- (NSString *)getLocalToken{

    return [[NSUserDefaults standardUserDefaults]objectForKey:LOCAL_TOKEN];
}

- (void)saveLocalToken:(NSString *)token{

    [[NSUserDefaults standardUserDefaults]setObject:token forKey:LOCAL_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (AFHTTPSessionManager *)manager{

    if (!_manager) {
        
        _manager = [AFHTTPSessionManager manager];
        
        [_manager setSecurityPolicy:[self customSecurityPolicy]];

//        _manager.securityPolicy.allowInvalidCertificates = YES;
//        _manager.securityPolicy.validatesDomainName = NO;
//        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
       
    }
    return _manager;
}

- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"*.ihealthlabs.com.cn" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = [NSSet setWithObject:certData];
    
    return securityPolicy;
}
@end
