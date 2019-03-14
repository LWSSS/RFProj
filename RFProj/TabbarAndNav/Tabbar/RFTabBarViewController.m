//
//  RFTabBarViewController.m
//  RFProj
//
//  Created by liuwei on 2019/3/13.
//  Copyright © 2019年 com.LW. All rights reserved.
//

#import "RFTabBarViewController.h"
#import "MessageViewController.h"
#import "AddressListViewController.h"
#import "ApplicationViewController.h"
#import "UserCenterViewController.h"
#import "RFNavigationController.h"


@interface RFTabBarViewController ()

@end

@implementation RFTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.translucent=NO;
    [self setTabBarViewController];
    
    // Do any additional setup after loading the view.
}

-(void)setTabBarViewController{
    [self setChildVCWithTitle:@"消息" image:[UIImage imageNamed:@"recommendation_1"] selectImage:[UIImage imageNamed:@"recommendation_2"] ViewController:[[MessageViewController alloc]init]];
    
    [self setChildVCWithTitle:@"通讯录" image:[UIImage imageNamed:@"broadwood_1"] selectImage:[UIImage imageNamed:@"broadwood_2"] ViewController:[[AddressListViewController alloc]init]];
    
    [self setChildVCWithTitle:@"应用" image:[UIImage imageNamed:@"classification_1"] selectImage:[UIImage imageNamed:@"classification_2"] ViewController:[[ApplicationViewController alloc]init]];
    
    [self setChildVCWithTitle:@"我" image:[UIImage imageNamed:@"my_1"] selectImage:[UIImage imageNamed:@"my_2"] ViewController:[[UserCenterViewController alloc]init]];
}

-(void)setChildVCWithTitle:(NSString *)title image:(UIImage *)image selectImage:(UIImage *)selectImage ViewController:(UIViewController *)viewController{
    
    RFNavigationController * vc =[[RFNavigationController alloc]initWithRootViewController:viewController];
    
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.title = title;
    viewController.tabBarItem.image = image;
    viewController.tabBarItem.selectedImage = selectImage;
    [self   addChildViewController:vc];
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
