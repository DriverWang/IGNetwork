//
//  IGBaseNetwork.m
//
//
//  Created by ihealth-wyc on 16/8/11.
//  Copyright © 2016年 ihealth-wyc. All rights reserved.
//

#import "IGBaseNetwork.h"
#import <AFNetworking.h>

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
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

- (void)getAccessTokenWithSuccess:(success)success withFail:(getFail)fail {

    [self POSTRequestWithUrlString:GET_TOKEN parameter:@{@"AppVersion":[self getAppVersion]} success:^(id responseTask) {
        
        NSDictionary * dict = responseTask;
        NSString * token = dict[@"ReturnValue"][0][@"AccessToken"];
        [self saveLocalToken:token];
        
        if (success) {
            success(responseTask);
        }

    } fail:fail];
}

- (NSString *)getAppVersion{
   
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));

//    return [NSString stringWithFormat:@"%@+%@",[[NSBundle mainBundle] bundleIdentifier],[infoDictionary objectForKey:@"CFBundleShortVersionString"]];

    return @"123";
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

    }
    return _manager;
}
@end