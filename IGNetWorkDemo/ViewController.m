//
//  ViewController.m
//  IGNetWorkDemo
//
//  Created by ihealth-wyc on 16/8/12.
//  Copyright © 2016年 ihealth-wyc. All rights reserved.
//

#import "ViewController.h"
#import "IGBaseNetwork.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[IGBaseNetwork IGBaseNetworkManager]setUpBaseURL:@"http://120.92.57.192:3000"];

    [[IGBaseNetwork IGBaseNetworkManager]POSTRequestWithUrlString:@"/gdh/queryByCountryCode" parameter:@{@"CountryCode":@"CN"} accessTokenIfNeed:NO success:^(id responseTask) {
        
        
        
    } fail:^(NSInteger status, NSInteger resultMessage) {
        
    }];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSDictionary * dict = @{ @"AppVersion" : @"4.1.0",
                             @"CountryCode" : @"CN",
                             @"DeviceId" : @"91C0A346-63D2-4C01-9548-1E7AD7D64CAE",
                             @"DeviceType" : @"iPhone OS 8.3",
                             @"MeasurementTime" : @"2016-08-12 11:13:05",
                             @"TimeZone" : @"8",
                             @"UserID" : @"1560321",
                             @"UserName" : @"jjj",
                             @"mDeviceId" : @"1f53af558e",
                             @"mDeviceType" : @"BG1",
                             @"stripNumber" : @"1"};
    
    [[IGBaseNetwork IGBaseNetworkManager]POSTRequestWithUrlString:@"/gdh/insertGdhInfo" parameter:dict accessTokenIfNeed:YES success:^(id responseTask) {
        
        
    } fail:^(NSInteger status, NSInteger resultMessage) {
        
    }];
}


@end
