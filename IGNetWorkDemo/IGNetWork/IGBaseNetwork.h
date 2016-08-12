//
//  IGBaseNetwork.h
//  
//
//  Created by ihealth-wyc on 16/8/11.
//  Copyright © 2016年 ihealth-wyc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^success)(id responseTask);
typedef void(^fail)(NSError *error);
typedef void(^getFail)(NSInteger status, NSInteger resultMessage);
typedef void(^networkBlock) (BOOL isNetworking);

@interface IGBaseNetwork : NSObject


/**
 *  @author YC, 16-08-11 16:08:30
 *
 *  单例方法
 *
 *  @return IGBaseNetwork
 */
+ (instancetype)IGBaseNetworkManager;


/**
 *  @author YC, 16-08-11 16:08:13
 *
 *  设置基础URL
 *
 *  @param baseURL URL地址
 */
- (void)setUpBaseURL:(NSString *)baseURL;

/**
 *  @author YC, 16-08-11 16:08:01
 *
 *  POST 请求
 *
 *  @param urlString    接口地址
 *  @param parameter    POST参数
 *  @param need         是否需要传入token
 *  @param successBlock 成功回调
 *  @param failBlock    失败回调
 */

- (void)POSTRequestWithUrlString:(NSString *)urlString parameter:(NSDictionary *)parameter accessTokenIfNeed:(BOOL)need success:(success)successBlock fail:(getFail)failBlock;


@end
