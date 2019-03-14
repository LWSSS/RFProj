//
//  RFNavigationController.m
//  RFProj
//
//  Created by liuwei on 2019/3/13.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import "RFNavigationController.h"

@interface RFNavigationController ()

@end

@implementation RFNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed=YES;
        [super pushViewController:viewController animated:YES];
    }else{
        [super pushViewController:viewController animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
