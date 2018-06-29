//
//  ViewController.m
//  WKWebView-Cookie
//
//  Created by lppz02 on 2018/6/29.
//  Copyright © 2018 lppz02. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "LoginViewController.h"

@interface ViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LoginSuccessNotification" object:nil];
    }

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    //
    configuration.processPool = [[WKProcessPool alloc] init];

    WKUserContentController *userController = [[WKUserContentController alloc] init];
    configuration.userContentController     = userController;
    // 允许在线播放
    configuration.allowsInlineMediaPlayback = YES;
    // 是否支持记忆读取
    configuration.suppressesIncrementalRendering = YES;
    //初始化偏好设置属性：preferences
    configuration.preferences = [[WKPreferences alloc] init];
    //是否支持JavaScript
    configuration.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //注册回调
    [userController addScriptMessageHandler:self name:@"loginLppzRefresh"];

    self.webView = [[WKWebView alloc] initWithFrame:(CGRect){0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height} configuration:configuration];
    self.configuration = configuration;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.allowsLinkPreview = YES;//允许链接3D Touch

    //存储Cookie
    [self saveCookie];

    [self.view addSubview:self.webView];

    if (@available(iOS 11.0, *)) {
        [self.webView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.19.60/test/test-coo1.html"]];
    [self.webView loadRequest:request];

}

- (void)loginSuccess {
    [self updateWebViewCookie];
}

- (void)saveCookie {
    //公司的域名
    NSString *domain = @"192.168.19.60";
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
                                                                     NSHTTPCookieDomain: domain,
                                                                     NSHTTPCookieName: @"params", //cookie名字
                                                                     NSHTTPCookieValue: @"login", //cookie值
                                                                     NSHTTPCookiePath: @"/", //路径，一般都是存在根目录下
                                                                     NSHTTPCookieExpires: [[NSDate date] dateByAddingTimeInterval:2629743] //过期时间
                                                                     }];
        [cookieStore setCookie:cookie completionHandler:^{
            NSLog(@"success");
        }];
    } else {
        NSString *cookieValue = @"";
        NSString *cookie = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@", @"params" , @"login", domain, @"/"];
        cookieValue = [cookieValue stringByAppendingString:[NSString stringWithFormat:@"document.cookie='%@';", cookie]];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieValue injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.configuration.userContentController addUserScript:cookieScript];
    }
}

/*!
 *  更新webView的cookie
 */
- (void)updateWebViewCookie {
    //公司的域名
    NSString *domain = @"192.168.19.60";
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{
                                                                    NSHTTPCookieDomain: domain,
                                                                    NSHTTPCookieName: @"params", //cookie名字
                                                                    NSHTTPCookieValue: @"loginSuccess", //cookie值
                                                                    NSHTTPCookiePath: @"/", //路径，一般都是存在根目录下
                                                                    NSHTTPCookieExpires: [[NSDate date] dateByAddingTimeInterval:2629743] //过期时间
                                                                    }];
        [cookieStore setCookie:cookie completionHandler:^{
            NSLog(@"success");
        }];
    } else {
        NSString *cookieValue = @"";
        NSString *cookie = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@", @"params" , @"loginSuccess", domain, @"/"];
        cookieValue = [cookieValue stringByAppendingString:[NSString stringWithFormat:@"document.cookie='%@';", cookie]];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieValue injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.configuration.userContentController addUserScript:cookieScript];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {

    decisionHandler(WKNavigationResponsePolicyAllow);
}


#pragma mark - WKScriptMessageHandler  js -> oc
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {

    if ([message.name isEqualToString:@"loginLppzRefresh"]) {

        LoginViewController *loginVc = [[LoginViewController alloc] init];

        [self presentViewController:loginVc animated:YES completion:^{
        }];

    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(nonnull void (^)(void))completionHandler
{
    //js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        completionHandler(NO);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    //用于和JS交互，弹出输入框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        completionHandler(nil);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [self presentViewController:alertController animated:YES completion:NULL];
}


@end
