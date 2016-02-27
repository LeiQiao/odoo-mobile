//
//  ViewController.m
//  odooMobile
//
//  Created by lei.qiao on 16/2/27.
//  Copyright © 2016年 LeiQiao. All rights reserved.
//

#import "ViewController.h"
#import "AFXMLRPCSessionManager.h"

@interface ViewController ()

@end

@implementation ViewController {
    AFXMLRPCSessionManager* _xmlrpcManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _xmlrpcManager = [[AFXMLRPCSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.1.109:8069/xmlrpc/2/common"]];
    
    NSURLRequest* request = [_xmlrpcManager XMLRPCRequestWithMethod:@"authenticate"
                                                         parameters:@[@"ai_run", @"乔磊", @"admin", @{}]];
    
    [_xmlrpcManager XMLRPCTaskWithRequest:request
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
