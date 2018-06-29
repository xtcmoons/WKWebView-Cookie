//
//  LoginViewController.m
//  WKWebView-Cookie
//
//  Created by lppz02 on 2018/6/29.
//  Copyright © 2018 lppz02. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *loginButton = [[UIButton alloc] initWithFrame:(CGRect){100, 100, 50, 50}];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:loginButton];
}

- (void)login {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
