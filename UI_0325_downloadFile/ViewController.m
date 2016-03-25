//
//  ViewController.m
//  UI_0325_downloadFile
//
//  Created by scuplt on 16-3-24.
//  Copyright (c) 2016年 itcast0413. All rights reserved.
//

#import "ViewController.h"
#import "myFileDownLoad.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *showPic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    
 myFileDownLoad *load=   [[myFileDownLoad alloc] init];
    [load downloadFilewithURL:[NSURL URLWithString:@"http://localhost/it1/pic/7.png"] andCompletion:^(UIImage *image) {
        self.showPic.image=image;
    }];
}
@end
