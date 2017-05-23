//
//  ViewController.m
//  奥迪康助听器
//
//  Created by 上海点硕 on 2017/4/13.
//  Copyright © 2017年 cbl－　点硕. All rights reserved.
//

#import "ViewController.h"
#import "XLBallLoading.h"
#import <UMSocialCore/UMSocialCore.h>
#import<WebKit/WebKit.h>
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width            // 屏幕宽
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height          // 屏幕高
@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic , strong)WKWebView *webView;
@end

@implementation ViewController
{
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor whiteColor];
    [self makeUI];

}
//status  become  white
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)makeUI
{
    
    
    UIView *view = [UIView new];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor colorWithRed:46/255.0 green:47/255.0 blue:49/255.0 alpha:1];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
    

    
    //初始化一个WKWebViewConfiguration对象
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    WKUserContentController *contentContentController = [[WKUserContentController alloc] init];
    [contentContentController addScriptMessageHandler:self name:@"loginActive"];
    config.userContentController = contentContentController;
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20) configuration:config];
    [self.view addSubview:self.webView];
    NSURL *url = [NSURL URLWithString:@"http://aodikang.idea-source.net"];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

//- (void)loginActive
//{
//   
//    NSDictionary *dic = @{
//                          @"UnionId" :@"1234567890",
//                          @"nickName" :@"奥特曼",
//                          @"faceImg"  :@"嘻嘻嘻嘻.png",
//                          @"gender"    :@"男"
//                          };
//    
//    NSString *promptCode = [NSString stringWithFormat:@"appCallback(\"%@\")",dic];
//    [self.webView evaluateJavaScript:promptCode completionHandler:^(id object, NSError * _Nullable error) {
//        
//        NSLog(@"=============%@",object);
//    }];
// 
//}
//微信登陆
- (void)weixin
{
    // 在需要进行获取登录信息的UIViewController中加入如下代
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:self completion:^(id result, NSError *error) {
            NSLog(@"%@",error);
            UMSocialUserInfoResponse *resp = result;
            // 第三方登录数据(为空表示平台未提供)
            NSLog(@">>>>>>>>>%@",resp);
            NSLog(@" uid: %@", resp.uid);
            NSLog(@" openid: %@", resp.openid);
            NSLog(@" accessToken: %@", resp.accessToken);
            NSLog(@" refreshToken: %@", resp.refreshToken);
            NSLog(@" expiration: %@", resp.expiration);
            //用户数据
            NSLog(@" name: %@", resp.name);
            NSLog(@" iconurl: %@", resp.iconurl);
            NSLog(@" gender: %@", resp.gender);
            //第三方平台SDK原始数据
            NSLog(@" originalResponse: %@", resp.originalResponse);
            //appCallback(UnionId,nickName,faceImg,gender)
            if (resp.uid==nil) {
         
                resp.uid =@"";
                resp.name =@"";
                resp.iconurl =@"";
               resp.gender = @"";
            }
         
            NSDictionary *data1 = @{
                                  @"unionId" :resp.uid,
                                  @"nickName" :resp.name,
                                  @"faceImg"  :resp.iconurl,
                                  @"gender"    :resp.gender
                                  };
            
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:data1 options:NSJSONWritingPrettyPrinted error:nil];
            NSString *paraStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // 将JSON字符串转成无换行无空格字符串
            paraStr = [self becomeStr:paraStr];
            NSString *method = [NSString stringWithFormat:@"appCallback('%@')",paraStr];
            
            NSLog(@"JJJJJJJJ======%@",method);
            
            [self.webView evaluateJavaScript:method completionHandler:^(id data, NSError * _Nullable error) {
                
                NSLog(@"=============%@",error);
                
            }];
        }];
}


- (NSString *)becomeStr:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@" " withString: @""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString: @""];
    return str;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([@"loginActive" isEqualToString:message.name]) {
        
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray, NSDictionary,NSNull类型
        [self weixin];
        NSLog(@"%@", message.body);
        
        NSLog(@"IOS login");
    }
}
//开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigatio{
    
   //开始加载网页调用此方法
    [self show];
}

//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //网页加载完成调用此方法
    [self hide];
    
    [self.webView evaluateJavaScript:@"appIosCheck()" completionHandler:^(id appIosCheck, NSError * _Nullable error) {
        
        NSLog(@"嘿嘿嘿");
    }];
}


-(void)show{
    //显示BallLoading
    [XLBallLoading showInView:self.view];
}


-(void)hide{
    //隐藏BallLoading
    [XLBallLoading hideInView:self.view];
}



- (void)dealloc
{
  [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"loginActive"];
}



@end
